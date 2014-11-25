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

wget https://dl.bintray.com/mitchellh/packer/packer_0.7.2_linux_amd64.zip
sudo apt-get install -y unzip git python-pip qemu-utils openstack-debian-images
unzip packer*.zip -d /usr/local/bin/

sudo pip install python-openstackclient python-glanceclient

cd /root/
git co https://github.com/Chealion/openstack-images.git packer

touch /.provisioned
