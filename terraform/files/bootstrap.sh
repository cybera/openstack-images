#! /bin/bash

if [ -f /.provisioned ]; then
    echo 'Skipping bootstrap.sh'
    exit 0
fi

cd

echo 'Acquire::http { Proxy "http://acng-yyc.cloud.cybera.ca:3142"; };' | sudo tee /etc/apt/apt.conf.d/02proxy

sudo locale-gen en_CA.UTF-8

lsb_release -a

sudo apt-get update
sudo apt-get -y upgrade

wget https://releases.hashicorp.com/packer/1.7.8/packer_1.7.8_linux_amd64.zip

sudo apt-get install -y unzip git python-pip qemu-utils openstack-debian-images
sudo unzip packer*.zip -d /usr/local/bin/

sudo apt-get install -y python3-pip libssl-dev build-essential libffi-dev python3-dev python3-openssl
pip3 install \
  python-openstackclient \
  python-novaclient \
  python-keystoneclient \
  python-swiftclient \
  python-glanceclient \
  python-cinderclient \
  python-neutronclient \
  python-ceilometerclient \
  python-troveclient \
  python-heatclient

echo “PATH=\$PATH:$HOME/packer” >> $HOME/.profile
source $HOME/.profile


sudo git clone https://github.com/cybera/openstack-images.git /root/packer

git clone https://github.com/cybera/cybera-dotfiles cybera-dotfiles
chmod 755 ./cybera-dotfiles/create.sh
./cybera-dotfiles/create.sh

sudo touch /.provisioned
