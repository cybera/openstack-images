#!/bin/bash

#Manual Installer for the Tools for Debian based distros. Tested with Ubuntu 14.04

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install git unzip
cd $HOME
wget -q https://releases.hashicorp.com/packer/1.7.8/packer_1.7.8_linux_amd64.zip
mkdir packer
unzip -d packer packer_1.7.8_linux_amd64.zip
rm packer_1.7.8_linux_amd64.zip

sudo apt-get install -y python3-pip libssl-dev build-essential libffi-dev python3-dev python3-openssl
pip3 install --upgrade pip
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
