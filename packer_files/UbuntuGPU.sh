#! /bin/bash -x

# This script installs the drivers for the NVIDIA graphics cards

cat > /etc/modprobe.d/blacklist-nouveau.conf <<EOF
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF
 
echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf

rmmod nouveau

echo options nouveau modeset=0 | tee -a /etc/modprobe.d/nouveau-kms.conf
 
update-initramfs -u

sudo apt-get update
sudo apt-get install -y python-software-properties

sudo apt-add-repository -y ppa:graphics-drivers/ppa
sudo apt-get update
sudo apt-get install -y build-essential make
sudo apt-get install -y linux-image-extra-virtual linux-headers-generic
sudo apt-get install -y nvidia-361

wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb
sudo dpkg -i cuda*.deb
sudo apt-get update
sudo apt-get install -y cuda
sudo rm -rf cuda*.deb

#Ensure changes are written to disk
sync
