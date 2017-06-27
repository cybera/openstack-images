#! /bin/bash -x

export DEBIAN_FRONTEND=noninteractive
/usr/local/bin/localSUS

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
sudo apt-get install -y python-software-properties
sudo apt-add-repository -y ppa:graphics-drivers/ppa

sudo apt-get update
sudo apt-get install -y linux-image-extra-virtual linux-headers-generic
sudo apt-get install -y build-essential 
sudo apt-get update
sudo apt-get install -y dictionaries-common
sudo apt-get install -y nvidia-375 nvidia-modprobe
sudo apt-get install -y xubuntu-desktop libglu1-mesa-dev libx11-dev freeglut3-dev mesa-utils


wget -q https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda_8.0.44_linux-run
sudo chmod +x cuda_*
sudo mkdir nvidia_installers
sudo ./cuda* -extract=`pwd`/nvidia_installers
cd nvidia_installers
sudo ./cuda-linux64-rel-8.0.44-21122537.run -noprompt
sudo ./cuda-samples-linux-8.0.44-21122537.run -noprompt -cudaprefix=/usr/local/cuda-8.0

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
# K80 = 0:5:0??
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
    BusID          "0:5:0"
EndSection
Section "Screen"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    Option         "UseDisplayDevice" "None"
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

cat << EOF | sudo tee /etc/ld.so.conf.d/ld-library.conf
# Add CUDA to LD
/usr/local/cuda/lib64
EOF

sudo ldconfig

# Clean up
cd
sudo rm -rf cuda*
sudo rm -rf nvidia_installers
sudo rm -rf /tmp/*
sudo rm /etc/apt/apt.conf.d/02proxy
sudo rm -rf /var/crash/*
sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id
sudo apt-get clean

#Ensure changes are written to disk
sync
