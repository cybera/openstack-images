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
#wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-470.103.02-470.103.01-472.98.zip
wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/NVIDIA-GRID-Linux-KVM-525.125.03-525.125.06-529.11.zip

unzip NVIDIA-GRID-Linux-KVM-*.zip
cd Guest_Drivers
chmod 755 ./NVIDIA-Linux-x86_64-*-grid.run

sudo apt-get install -y nvidia-modprobe

echo " ====> Installing vGPU Driver"
sudo ./NVIDIA-Linux-x86_64-*-grid.run --dkms --skip-module-unload -as -k $(ls --sort time /boot | grep vmlinuz- | head -n 1 | sed 's/vmlinuz-//')

# Cleanup NVIDIA
rm -rf *.pdf
rm -rf *.exe
rm -rf *.zip
rm -rf *.run

# Set up licensing
sudo mkdir -p /etc/nvidia
cat << EOF | sudo tee /etc/nvidia/gridd.conf
ServerAddress=
ServerPort=
FeatureType=2
EnableUI=False
LicenseInterval=1440
EOF
sudo mkdir -p /etc/nvidia/ClientConfigToken

echo " ====> Placing Config Token"

wget -q https://swift-yyc.cloud.cybera.ca:8080/v1/AUTH_8c4974ed39a44c2fabd9d75895f6e28b/cybera_public/client_configuration_token_canarie.tok

sudo mv client_configuration_token_canarie.tok /etc/nvidia/ClientConfigToken

echo " ====> Downloading CUDA"
#10.1 not supported by latest vGPU driver (410.92)
#wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run
#wget -q https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
#wget -q https://developer.download.nvidia.com/compute/cuda/11.0.3/local_installers/cuda_11.0.3_450.51.06_linux.run
#wget https://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda_11.2.2_460.32.03_linux.run
#wget https://developer.download.nvidia.com/compute/cuda/11.5.0/local_installers/cuda_11.5.0_495.29.05_linux.run
wget -q https://developer.download.nvidia.com/compute/cuda/11.6.2/local_installers/cuda_11.6.2_510.47.03_linux.run
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
sudo rm -rf /home/ubuntu/*
sudo apt-get clean

#Ensure changes are written to disk
sync

