#! /bin/bash -x

# This script installs the drivers for the NVIDIA graphics cards

sudo yum -y update
sudo yum -y install kernel-devel kernel-headers pciutils
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
sudo yum -y install kmod-nvidia

sudo yum -y install perl-Env

# Tarball
curl http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run -o cuda_7.5.18_linux.run
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

#Ensure changes are written to disk
sync
