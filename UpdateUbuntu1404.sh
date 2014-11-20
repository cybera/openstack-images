#! /bin/bash
source racrc

# Download the latest version
wget -N https://cloud-images.ubuntu.com/daily/server/trusty/current/trusty-server-cloudimg-amd64-disk1.img

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file trusty-server-cloudimg-amd64-disk1.img TempUbuntuImage | grep id | awk ' { print $4 }'`

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    Ubuntu1404.json

openstack image delete TempUbuntuImage

echo "Image Available on RAC!"

# Grab Image and Upload to DAIR
openstack image save $glance_id --file 1404.img

source dairrc
openstack image create --disk-format qcow2 --container-format bare --file 1404.img "Ubuntu 14.04"

echo "Image Available on DAIR!"
