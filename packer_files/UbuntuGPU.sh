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

wget http://developer.download.nvidia.com/compute/cuda/6_0/rel/installers/cuda_6.0.37_linux_64.run
chmod +x cuda_*
mkdir nvidia_installers
./cuda* -extract=`pwd`/nvidia_installers
cd nvidia_installers
sudo ./cuda-samples-linux-6.0.37-18176142.run -noprompt
sudo ./cuda-linux64-rel-6.0.37-18176142.run -noprompt

#Ensure changes are written to disk
sync
