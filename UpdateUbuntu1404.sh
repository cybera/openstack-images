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

openstack server create --image "Ubuntu 14.04 Test" --flavor 2 --key-name cyberaMenlo PackerTest 
sleep 10
openstack server show "PackerTest"

# Run Packer on DAIR
source dairrc

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file trusty-server-cloudimg-amd64-disk1.img TempUbuntuImage | grep id | awk ' { print $4 }'`

packer build \
    -var 'source_image=#{glance_id}' \
    Ubuntu1404.json

