#!/bin/bash

#Manual Installer for the Tools for Debian based distros. Tested with Ubuntu 16.04

apt-get update
apt-get -y upgrade
apt-get -y install git unzip
cd $HOME
wget https://releases.hashicorp.com/packer/1.6.1/packer_1.6.1_linux_amd64.zip
mkdir packer
unzip -d packer_1.6.1_linux_amd64.zip
rm packer_1.6.1_linux_amd64.zip

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
