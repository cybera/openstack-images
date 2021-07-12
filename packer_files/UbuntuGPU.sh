#! /bin/bash -x

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
sudo apt-get -y upgrade

sudo apt-get update
sudo apt-get install -y dkms linux-headers-generic
sudo apt-get install -y build-essential
sudo apt-get update

#grep 14 /etc/lsb-release > /dev/null
#if [ $? -eq 0 ]; then
  #sudo apt-get install -y nvidia-367=367.57-0ubuntu0.14.04.1 nvidia-modprobe
  sudo apt-get install -y nvidia-modprobe
  cd /tmp
  #wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_ca447e24e0f84eab8e6f6b93703b774a/public_files/NVIDIA-GRID-Linux-KVM-450.89-452.57.zip
  wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-460.73.02-460.73.01-462.31.zip
  unzip /tmp/NVIDIA-GRID-Linux-KVM-*.zip
  chmod +x /tmp/NVIDIA-*kvm.run
  sudo /tmp/NVIDIA-Linux-x86_64-*-vgpu-kvm.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
#else
  #sudo apt-get install -y gcc-4.9 g++-4.9
  #sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 20
  #sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 10
  #sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 20
  #sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 10
  #sudo update-alternatives --set gcc "/usr/bin/gcc-4.9"
  #sudo update-alternatives --set g++ "/usr/bin/g++-4.9"
#  sudo apt-get install -y nvidia-modprobe
#  cd /tmp
#  wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/367.57/NVIDIA-Linux-x86_64-367.57.run
#  chmod +x /tmp/NVIDIA*
#  sudo /tmp/NVIDIA-Linux-x86_64-367.57.run --dkms -as
#  sudo /tmp/NVIDIA-Linux-x86_64-367.57.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
#  sudo nvidia-smi
#fi

# Install extras after driver so that dkms will build in case kernel was updated.
sudo apt-get install -y dkms linux-image-extra-virtual linux-headers-generic

sudo apt-get install -y xubuntu-desktop libglu1-mesa-dev libx11-dev freeglut3-dev mesa-utils

wget -q http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda_8.0.44_linux-run
sudo chmod +x cuda_*
sudo mkdir nvidia_installers
sudo ./cuda* -extract=`pwd`/nvidia_installers
cd nvidia_installers
sudo ./cuda-linux64-rel-7.5.18-19867135.run -noprompt
#sudo ./cuda-linux64-rel-8.0.44-21122537.run -noprompt
sudo ./cuda-samples-linux-7.5.18-19867135.run -noprompt -cudaprefix=/usr/local/cuda-7.5
#sudo ./cuda-samples-linux-8.0.44-21122537.run -noprompt -cudaprefix=/usr/local/cuda-8.0

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
# K80 = 0:6:0
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
    BusID          "0:7:0"
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

# Reinstall driver - because figuring out what's overwriting would take long /shrug
sudo /tmp/NVIDIA-Linux-x86_64-367.57.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
sudo nvidia-smi

# Clean up
cd
sudo rm -rf /{root,home/ubuntu,home/debian}/{.ssh,.bash_history,/*} && history -c
sudo rm -rf cuda*
sudo rm -rf nvidia_installers
sudo rm -rf /tmp/*
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /var/log/journal/*
sudo rm /etc/machine-id
sudo touch /etc/machine-id
sudo rm -rf /var/lib/dbus/machine-id
sudo rm /var/lib/systemd/timers/*
sudo rm /etc/apt/apt.conf.d/02proxy
sudo rm -rf /var/crash/*
sudo apt-get -y clean

# Clean up
cd

#Ensure changes are written to disk
sync

