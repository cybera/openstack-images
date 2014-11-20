#! /bin/bash

# Install OpenStack!
sudo apt-get update
sudo apt-get install -y python-pip

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
