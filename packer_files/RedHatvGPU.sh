#! /bin/bash -x

# This script installs the drivers for the NVIDIA graphics cards

sudo yum -y update
sudo yum -y install kernel-devel kernel-headers gcc make pciutils --disableexcludes=all
sudo yum -y groupinstall "Development Tools"
sudo yum -y install unzip

cat <<EOF | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo blacklist nouveau | sudo tee -a /etc/modprobe.d/blacklist.conf

sudo mv /home/centos/local-module.pp /usr/share/selinux/targeted/gpu-access.pp
sudo mv /home/centos/local-module.te /usr/share/selinux/targeted/gpu-access.te
sudo semodule -i /usr/share/selinux/targeted/gpu-access.pp

sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

sudo yum install -y perl-Env wget epel-release

sudo yum -y update
sudo yum -y install dkms

# Install vGPU Driver
wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-460.73.02-460.73.01-462.31.zip
unzip NVIDIA-GRID-Linux-KVM-*.zip
chmod 755 NVIDIA-Linux-x86_64-*-grid.run

sudo yum -y install nvidia-modprobe

echo " ====> Installing vGPU Driver"
sudo ./NVIDIA-Linux-x86_64-*-grid.run --dkms --skip-module-unload -as -k $(ls /boot | grep vmlinuz- | tail -n 1 | sed 's/vmlinuz-//')

# Set up licensing
mkdir -p /etc/nvidia
cat << EOF | sudo tee /etc/nvidia/gridd.conf
ServerAddress=nvidia.dair-atir.canarie.ca
ServerPort=7070
FeatureType=2
EnableUI=False
LicenseInterval=1440
EOF

# Install CUDA
# 10.1 not supported by 410.92 driver. Need 418.xx+ to be released
#wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
wget https://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda_11.2.2_460.32.03_linux.run
sudo chmod +x cuda_*

sudo ./cuda* --silent --toolkit --samplespath=/usr/local/cuda/samples

cat << EOF | sudo tee /etc/ld.so.conf.d/ld-library.conf
# Add CUDA to LD
/usr/local/cuda/lib64
EOF

sudo ldconfig

sudo yum clean all

# Cleanup NVIDIA
rm -rf *.pdf
rm -rf *.exe
rm -rf *.zip
rm -rf *.run
rm -rf cuda*

sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c
sudo rm -rf /root/NVIDIA*

cat "" | sudo tee /etc/hostname

sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id

sudo systemctl disable firewalld

#Ensure changes are written to disk
sync
