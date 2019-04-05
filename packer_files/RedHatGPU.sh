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

sudo mv /home/centos/local-module.pp /usr/share/selinux/targeted/gpu-access.pp
sudo mv /home/centos/local-module.te /usr/share/selinux/targeted/gpu-access.te
sudo semodule -i /usr/share/selinux/targeted/gpu-access.pp

sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum -y install kmod-nvidia

sudo yum install -y perl-Env wget epel-release

# Install CUDA
wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run
sudo chmod +x cuda_*

# 10.1 needs samples specified - 10.0 installer was fine
sudo ./cuda* --silent --toolkit --samples --samplespath=/usr/local/cuda/samples
sudo rm -rf /root/NVIDIA*

cat << EOF | sudo tee /etc/ld.so.conf.d/ld-library.conf
# Add CUDA to LD
/usr/local/cuda/lib64
EOF

sudo ldconfig

sudo yum clean all
sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c
sudo rm -rf /home/centos/*
sudo rm -rf /var/lib/cloud/*
sudo rm /var/lib/systemd/timers/*
sudo rm -rf /var/crash/*

cat "" | sudo tee /etc/hostname

sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id

sudo systemctl disable firewalld

#Ensure changes are written to disk
sync
