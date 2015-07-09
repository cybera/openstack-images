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

#wget https://dl.bintray.com/mitchellh/packer/packer_0.8.1_linux_amd64.zip
wget https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip
sudo apt-get install -y unzip git python-pip qemu-utils openstack-debian-images
wget http://ftp.de.debian.org/debian/pool/main/o/openstack-debian-images/openstack-debian-images_1.2.tar.xz
tar xvfJ openstack-debian-images_1.2.tar.xz
mv openstack-debian-images-1.2/build-openstack-debian-image /usr/sbin
rm -rf openstack*
unzip packer*.zip -d /usr/local/bin/

sudo pip install python-glanceclient

cd /root/
git clone https://github.com/cybera/openstack-images.git packer

touch /.provisioned
