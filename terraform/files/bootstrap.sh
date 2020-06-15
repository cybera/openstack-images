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

wget https://releases.hashicorp.com/packer/1.3.4/packer_1.3.4_linux_amd64.zip

sudo apt-get install -y unzip git python-pip qemu-utils openstack-debian-images
#wget http://ftp.de.debian.org/debian/pool/main/o/openstack-debian-images/openstack-debian-images_1.2.tar.xz
#tar xvfJ openstack-debian-images_1.2.tar.xz
#sudo mv openstack-debian-images-1.2/build-openstack-debian-image /usr/sbin
#rm -rf openstack*
sudo unzip packer*.zip -d /usr/local/bin/

sudo apt-get install -y python-glanceclient python-openstackclient python-novaclient python-keystoneclient python-neutronclient

sudo git clone https://github.com/cybera/openstack-images.git /root/packer

git clone https://github.com/cybera/cybera-dotfiles cybera-dotfiles
chmod 755 ./cybera-dotfiles/create.sh
./cybera-dotfiles/create.sh

sudo touch /.provisioned
