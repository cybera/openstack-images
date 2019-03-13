#! /bin/bash -x

export DEBIAN_FRONTEND=noninteractive

#Blacklist nouveau

cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo blacklist nouveau | sudo tee -a /etc/modprobe.d/blacklist.conf

rmmod nouveau

echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf

sudo update-initramfs -u

# nvidia drivers, cuda

sudo apt-get update
# Be extra explicit about noninteractive.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-extra-virtual linux-headers-generic build-essential unzip dkms

# Install vGPU Driver
echo " ====> Downloading vGPU Driver"
wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-410.92-410.91-412.16.zip
unzip NVIDIA-GRID-Linux-KVM-410.92-410.91-412.16.zip
chmod +x *.run

sudo apt-get install -y nvidia-modprobe

echo " ====> Installing vGPU Driver"
sudo ./NVIDIA-Linux-x86_64-410.92-grid.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')

# Cleanup NVIDIA
rm -rf *.pdf
rm -rf *.exe
rm -rf *.zip
rm -rf *.run

# Set up licensing
mkdir -p /etc/nvidia
cat << EOF | sudo tee /etc/nvidia/gridd.conf
ServerAddress=nvidia.dair-atir.canarie.ca
ServerPort=7070
FeatureType=2
EnableUI=False
LicenseInterval=1440
EOF

echo " ====> Downloading CUDA"
#10.1 not supported by latest vGPU driver (410.92)
#wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run
wget -q https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
sudo chmod +x cuda_*

echo " ====> Installing CUDA"
sudo ./cuda* --silent --toolkit --samplespath=/usr/local/cuda/samples

sudo apt-get install -y xubuntu-desktop libglu1-mesa-dev libx11-dev freeglut3-dev mesa-utils dictionaries-common

#TurboVNC and VirtualGL
cd
mkdir t
pushd t
wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_ca447e24e0f84eab8e6f6b93703b774a/public_files/virtualgl_2.5_amd64.deb
wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_ca447e24e0f84eab8e6f6b93703b774a/public_files/turbovnc_2.0.91_amd64.deb
sudo dpkg -i *.deb
popd
sudo rm -rf t

sudo chmod +s /usr/lib/libdlfaker.so
sudo chmod +s /usr/lib/libvglfaker.so

sudo /opt/VirtualGL/bin/vglserver_config -config +s +f +t

#Configure X11 and nvidia
# K1 = 0:7:0
# K80 = 0:5:0
# Titan Xp = ??
# P100 = 0:6:0
cat <<EOF | sudo tee /etc/X11/xorg.conf
Section "DRI"
        Mode 0666
EndSection

Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0"
    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
EndSection
Section "Files"
EndSection
Section "InputDevice"
    # generated from default
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/psaux"
    Option         "Emulate3Buttons" "no"
    Option         "ZAxisMapping" "4 5"
EndSection
Section "InputDevice"
    # generated from default
    Identifier     "Keyboard0"
    Driver         "kbd"
EndSection
Section "Monitor"
    Identifier     "Monitor0"
    VendorName     "Unknown"
    ModelName      "Unknown"
    HorizSync       28.0 - 33.0
    VertRefresh     43.0 - 72.0
    Option         "DPMS"
EndSection
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BusID          "0:6:0"
EndSection
Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    SubSection     "Display"
        Virtual     1280 1024
        Depth       24
    EndSubSection
EndSection

EOF
sudo chattr +i /etc/X11/xorg.conf

# Configure VNC
cd
mkdir .vnc
cat <<EOF | tee .vnc/xstartup.turbovnc
/opt/VirtualGL/bin/vglrun startxfce4 &
EOF

chmod +x .vnc/xstartup.turbovnc
touch .vnc/passwd
chown -R $(whoami): .vnc
sudo ln -s /etc/pam.d/passwd /etc/pam.d/turbovnc

cat <<EOF | sudo tee /etc/sysconfig/tvncservers
VNCSERVERS="1:ubuntu"
VNCSERVERARGS[1]="-securitytypes unixlogin -pamsession -geometry 1240x900 -depth 24"
EOF

sudo update-rc.d tvncserver defaults
sudo systemctl enable tvncserver

cat << EOF | sudo tee /etc/ld.so.conf.d/ld-library.conf
# Add CUDA to LD
/usr/local/cuda/lib64
EOF

sudo ldconfig

# Use networkd instead of network manager
sudo systemctl disable network-manager.service
sudo systemctl enable systemd-networkd.service

# Fix netplan so it can be properly rewritten on update
cat <<EOF | sudo tee /etc/netplan/50-cloud-init.yaml
network:
    version: 2
    ethernets:
        ens3:
            dhcp4: true
EOF
sudo netplan apply

# Make xfce4 the default terminal as gnome-terminal doesn't work via VNC
sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper

# Clean up
cd
sudo rm -rf cuda*
sudo rm -rf /root/NVIDIA*
sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c
sudo rm -rf /tmp/*
sudo rm /etc/apt/apt.conf.d/02proxy
sudo rm -rf /var/crash/*
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /var/log/journal/*
sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id
sudo rm -rf /var/lib/dbus/machine-id
sudo rm /var/lib/systemd/timers/*

sudo apt-get clean

#Ensure changes are written to disk
sync

