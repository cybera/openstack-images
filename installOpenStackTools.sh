#! /bin/bash

# Install OpenStack!

if [ -f /etc/debian_version ]; then

sudo apt-get update
sudo apt-get install -y python-pip

elif [ -f /etc/redhat-release ]; then

echo "Adding the EPEL repository..."

if [ "`rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3`" -ge 7 ]; then

cd /tmp
curl -O https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
sudo yum install -y /tmp/epel-release-7-2.noarch.rpm

elif [ "`rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3`" -eq 6 ]; then

cd /tmp
curl -O http://mirror-fpt-telecom.fpt.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
sudo yum install -y /tmp/epel-release-6-8.noarch.rpm

fi

sudo yum updateinfo
sudo yum install -y python-pip openssl-devel gcc libffi-devel python-devel

fi

sudo pip install python-openstackclient python-novaclient python-keystoneclient python-swiftclient python-glanceclient python-cinderclient python-neutronclient python-ceilometerclient python-troveclient python-heatclient

echo "The following OpenStack Command Line Tools have been installed:"
echo "  * openstack"
echo "  * nova"
echo "  * keystone"
echo "  * swift"
echo "  * glance"
echo "  * cinder"
echo "  * neutron"
echo "  * ceilometer"
echo "  * trove"
echo "  * heat"
echo ""
echo "Not all tools are supported by all OpenStack clouds."
