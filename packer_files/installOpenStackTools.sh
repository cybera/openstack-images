#! /bin/bash

# Install OpenStack!

if [ -f /etc/debian_version ]; then

    sudo apt-get update
    # Install packages - more explicit due to Debian
    sudo apt-get install -y python-pip libssl-dev build-essential libffi-dev python-dev python-openssl

elif [ -f /etc/redhat-release ]; then

    echo "Adding the EPEL repository..."

    # Check if version is > 7. (Matches Fedora 20, CentOS 7.0)
    if [ "`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora" | cut -d"-" -f3`" -ge 7 ]; then

        cd /tmp
        curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        sudo yum install -y /tmp/epel-release-latest-7.noarch.rpm

    fi

    sudo yum updateinfo
    sudo yum install -y python-pip openssl-devel gcc libffi-devel python-devel

fi

sudo pip install pytz python-openstackclient python-novaclient python-keystoneclient python-swiftclient python-glanceclient python-cinderclient python-neutronclient python-ceilometerclient python-troveclient python-heatclient python-designateclient

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
echo "  * designate"
echo ""
echo "Not all tools are supported by the Rapid Access Cloud."
