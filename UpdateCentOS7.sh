#! /bin/bash
source racrc

# Download the latest version
wget -N http://cloud.centos.org/centos/7/devel/CentOS-7-x86_64-GenericCloud.qcow2

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud.qcow2 TempCentOSImage | grep id | awk ' { print $4 }'`

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    CentOS7.json

openstack image delete TempCentOSImage

echo "Image Available on RAC!"

# Grab Image and Upload to DAIR
openstack image save $glance_id --file COS7.img

source dairrc
openstack image create --disk-format qcow2 --container-format bare --file COS7.img "CentOS 7.0"

echo "Image Available on DAIR!"
