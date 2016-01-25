#!/bin/bash

#Manual Installer for the Tools for Debian based distros. Tested with Ubuntu 14.04

apt-get update
apt-get -y upgrade
apt-get -y install git unzip
cd $HOME
wget https://dl.bintray.com/mitchellh/packer/packer_0.8.1_linux_amd64.zip
mkdir packer
unzip -d packer packer_0.8.1_linux_amd64.zip
rm packer_0.8.1_linux_amd64.zip

apt-get install -y python-pip libssl-dev build-essential libffi-dev python-dev python-openssl python-setuptools
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

# Get and install heat-cfn for image
cd $HOME
wget https://pypi.python.org/packages/source/h/heat-cfntools/heat-cfntools-1.4.2.tar.gz#md5=395e95fecdfa47a89e260998fd5e50b4
tar zxvf heat-cfntools-1.4.2.tar.gz
python heat-cfntools-1.4.2/setup.py build
python heat-cfntools-1.4.2/setup.py install
rm heat-cfntools-1.4.2.tar.gz
rm -rf heat-cfntools-1.4.2

echo “PATH=\$PATH:$HOME/packer” >> $HOME/.profile
source $HOME/.profile
