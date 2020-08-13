#!/bin/bash

#Manual Installer for the Tools for Debian based distros. Tested with Ubuntu 16.04

apt-get update
apt-get -y upgrade
apt-get -y install git unzip
cd $HOME
<<<<<<< HEAD
wget https://releases.hashicorp.com/packer/1.6.1/packer_1.6.1_linux_amd64.zip
mkdir packer
unzip -d packer_1.6.1_linux_amd64.zip
rm packer_1.6.1_linux_amd64.zip
=======
wget https://releases.hashicorp.com/packer/1.2.3/packer_1.2.3_linux_amd64.zip
mkdir packer
unzip -d /usr/local/bin/ packer_1.2.3_linux_amd64.zip
rm packer_1.2.3_linux_amd64.zip
>>>>>>> e2aa262c7eb66edcd3611dbe47c6fd9cb75fdbdc

apt-get install -y python-pip libssl-dev build-essential libffi-dev python-dev python-openssl
pip install \
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
