#! /bin/bash -x

# This script installs the drivers for the NVIDIA graphics cards

sudo yum -y update
sudo yum -y install kernel-devel kernel-headers gcc make pciutils --disableexcludes=all
sudo yum -y groupinstall "Development Tools"

cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo blacklist nouveau | sudo tee -a /etc/modprobe.d/blacklist.conf

sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
#sudo yum -y install kmod-nvidia-367.57-2.el7.elrepo nvidia-uvm-kmod-352.99-3.el7
sudo yum install -y wget perl-Env epel-release
sudo yum install -y dkms

cd /tmp
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/367.57/NVIDIA-Linux-x86_64-367.57.run
#wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/361.28/NVIDIA-Linux-x86_64-361.28.run
#chmod +x /tmp/NVIDIA*
#sudo /tmp/NVIDIA-Linux-x86_64-367.57.run --dkms -azs -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
#sudo nvidia-smi
#sudo /tmp/NVIDIA-Linux-x86_64-361.28.run -aqzs


# Install vGPU Driver
echo " ====> Downloading vGPU Driver"
#wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-410.92-410.91-412.16.zip
#unzip NVIDIA-GRID-Linux-KVM-410.92-410.91-412.16.zip
#chmod +x *.run

wget -q wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_ca447e24e0f84eab8e6f6b93703b774a/public_files/NVIDIA-GRID-Linux-KVM-450.102-450.102.04-452.77.zip
unzip NVIDIA-GRID-Linux-KVM-450.102-450.102.04-452.77.zip
chmod +x *.run

sudo apt-get install -y nvidia-modprobe

echo " ====> Installing vGPU Driver"
#sudo ./NVIDIA-Linux-x86_64-410.92-grid.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
sudo ./NVIDIA-Linux-x86_64-450.102.04-grid.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')

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

sudo yum install -y @xfce --skip-broken
sudo yum groupinstall -y "X Window System"
sudo yum install -y acpid mesa-libGL mesa-libGL-devel freeglut freeglut-devel
sudo systemctl set-default graphical.target

sudo yum install -y VirtualGL

wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_ca447e24e0f84eab8e6f6b93703b774a/public_files/turbovnc-2.0.91.x86_64.rpm
sudo rpm -Uhv turbovnc-2.0.91.x86_64.rpm
sudo vglserver_config -config +s +f +t

sudo chmod u+s /usr/lib64/VirtualGL/libdlfaker.so
sudo chmod u+s /usr/lib64/VirtualGL/librrfaker.so

cd /home/centos
mkdir .vnc
cat > .vnc/xstartup.turbovnc <<EOF
vglrun /usr/bin/startxfce4 &
EOF
chmod +x .vnc/xstartup.turbovnc
touch .vnc/passwd
chown -R centos: .vnc

sudo ln -fs /etc/pam.d/password-auth /etc/pam.d/turbovnc
cat <<EOF | sudo tee /etc/sysconfig/tvncservers
VNCSERVERS="1:centos"
VNCSERVERARGS[1]="-securitytypes unixlogin -pamsession -geometry 1240x900 -depth 24"
EOF
sudo chkconfig --level 345 tvncserver on

#Configure X11 and nvidia
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
Section "InputDevice"
    # generated from default
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/input/mice"
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

#wget http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-7.5-18.x86_64.rpm
#sudo rpm -i cuda-repo-rhel7-7.5-18.x86_64.rpm
sudo yum clean all

#sudo yum -y install cuda-7.5-18

#wget -q http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda_8.0.44_linux-run
#sudo chmod +x cuda_*
#sudo mkdir nvidia_installers
#sudo ./cuda* -extract=`pwd`/nvidia_installers
#cd nvidia_installers
#sudo ./cuda-linux64-rel-7.5.18-19867135.run -noprompt
#sudo ./cuda-linux64-rel-8.0.44-21122537.run -noprompt
#sudo ./cuda-samples-linux-7.5.18-19867135.run -noprompt -cudaprefix=/usr/local/cuda-7.5
#sudo ./cuda-samples-linux-8.0.44-21122537.run -noprompt -cudaprefix=/usr/local/cuda-8.0

echo " ====> Downloading CUDA"
#10.1 not supported by latest vGPU driver (410.92)
#wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
wget -q https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda_11.0.3_450.51.06_linux.run
sudo chmod +x cuda_*

echo " ====> Installing CUDA"
sudo ./cuda* --silent --toolkit --samplespath=/usr/local/cuda/samples

cat << EOF | sudo tee /etc/ld.so.conf.d/ld-library.conf
# Add CUDA to LD
/usr/local/cuda/lib64
EOF

sudo ldconfig
# Reinstall driver in cases where older driver was installed. Shouldn't be necessary but it happens enough.
sudo /tmp/NVIDIA-Linux-x86_64-367.57.run --dkms -azs -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
sudo nvidia-smi

sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c
sudo rm -rf /home/centos/*
sudo rm -rf /tmp/*

cat "" | sudo tee /etc/hostname

sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id

#Ensure changes are written to disk
sync
