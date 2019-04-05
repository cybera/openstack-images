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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y dkms linux-image-extra-virtual linux-headers-generic build-essential

wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run
sudo chmod +x cuda_*

sudo ./cuda* --extract=/tmp

# Install driver using dkms
sudo /tmp/NVIDIA*.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')

# Install CUDA
sudo ./cuda* --silent --toolkit --samples --samplespath=/usr/local/cuda-10.1/samples

cat << EOF | sudo tee /etc/ld.so.conf.d/ld-library.conf
# Add CUDA to LD
/usr/local/cuda/lib64
EOF

sudo ldconfig

# Clean up
cd
sudo rm -rf cuda*
sudo rm -rf /tmp/*
sudo rm -rf /{root,home/ubuntu,home/debian}/{.ssh,.bash_history,/*} && history -c
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /var/log/journal/*
sudo rm /etc/machine-id
sudo touch /etc/machine-id
sudo rm -rf /var/lib/dbus/machine-id
sudo rm /var/lib/systemd/timers/*
sudo rm /etc/apt/apt.conf.d/02proxy
sudo rm -rf /var/crash/*
sudo apt-get -y clean

#Ensure changes are written to disk
sync
