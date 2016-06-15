#! /bin/bash -x

# This script installs the drivers for the NVIDIA graphics cards

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

sudo apt-get update
sudo apt-get install -y python-software-properties

sudo apt-add-repository -y ppa:graphics-drivers/ppa
sudo apt-get update
sudo apt-get install -y build-essential make
sudo apt-get install -y linux-image-extra-virtual linux-headers-generic
sudo apt-get install -y nvidia-361

sudo wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run
sudo chmod +x cuda_*
sudo mkdir nvidia_installers
sudo ./cuda* -extract=`pwd`/nvidia_installers
cd nvidia_installers
sudo ./cuda-linux64-rel-7.5.18-19867135.run -noprompt
sudo ./cuda-samples-linux-7.5.18-19867135.run -noprompt -cudaprefix=/usr/local/cuda-7.5

# Clean up
cd
sudo rm -rf cuda*
sudo rm -rf nvidia_installers
sudo rm -rf /tmp/*

#Ensure changes are written to disk
sync
