#! /bin/bash
source racrc

# Download the latest version
wget -N https://cloud-images.ubuntu.com/daily/server/precise/current/precise-server-cloudimg-amd64-disk1.img

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file precise-server-cloudimg-amd64-disk1.img TempUbuntu12Image | grep id | awk ' { print $4 }'`

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    Ubuntu1204.json

openstack image delete TempUbuntuImage

# Grab Image and Upload to DAIR
openstack image save $glance_id --file 1204.img

source dairrc
openstack image create --disk-format qcow2 --container-format bare --file 1204.img Packer1204


