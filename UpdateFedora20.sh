#! /bin/bash
source racrc

# Download the latest version
wget -N http://download.fedoraproject.org/pub/fedora/linux/updates/20/Images/x86_64/Fedora-x86_64-20-20140407-sda.qcow2

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file Fedora-x86_64-20-20140407-sda.qcow2 TempFedoraImage | grep id | awk ' { print $4 }'`

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    Fedora20.json

openstack image delete TempFedoraImage

echo "Image Available on RAC!"

# Grab Image and Upload to DAIR
openstack image save $glance_id --file F20.img

source dairrc
openstack image create --disk-format qcow2 --container-format bare --file F20.img "Fedora 20"

echo "Image Available on DAIR!"
