#! /bin/bash -x

export DEBIAN_FRONTEND=noninteractive

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
# Be extra explicit about noninteractive.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-extra-virtual linux-headers-generic build-essential unzip dkms

# Install vGPU Driver
echo " ====> Downloading vGPU Driver"
#wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-410.92-410.91-412.16.zip
#unzip NVIDIA-GRID-Linux-KVM-410.92-410.91-412.16.zip
#chmod +x *.run

wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_ca447e24e0f84eab8e6f6b93703b774a/public_files/NVIDIA-GRID-Linux-KVM-450.102-450.102.04-452.77.zip
unzip NVIDIA-GRID-Linux-KVM-450.102-450.102.04-452.77.zip
chmod +x *.run

sudo apt-get install -y nvidia-modprobe

echo " ====> Installing vGPU Driver"
#sudo ./NVIDIA-Linux-x86_64-410.92-grid.run --dkms -as -k $(ls /boot | grep vmlinuz | tail -n 1 | sed 's/vmlinuz-//')
sudo ./NVIDIA-Linux-x86_64-450.102.04-grid.run --dkms -as -k $(ls /boot | grep vmlinuz- | tail -n 1 | sed 's/vmlinuz-//')

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

# Clean up
cd
sudo rm -rf cuda*
sudo rm -rf /root/NVIDIA*
sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c
sudo rm -rf /tmp/*
sudo rm /etc/apt/apt.conf.d/02proxy
sudo rm -rf /var/crash/*
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /var/log/journal/*
sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id
sudo rm -rf /var/lib/dbus/machine-id
sudo rm /var/lib/systemd/timers/*

sudo apt-get clean

#Ensure changes are written to disk
sync

