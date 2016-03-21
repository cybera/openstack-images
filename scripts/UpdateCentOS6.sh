#! /bin/bash

cd ../images
# Download the latest version - this URL will likely need updating
wget -N http://cloud.centos.org/centos/6/images/CentOS-6-x86_64-GenericCloud.qcow2c

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2c --name TempCentOSImage | grep id | awk ' { print $4 }'`

sleep 15

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    ../scripts/CentOS6.json $@ | tee ../logs/CentOS66.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "CentOS 6"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available!"
