#! /bin/bash
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="PackerCentOS6"
source ../rc_files/dairrc

cd ../images
# Download the latest version - this URL will likely need updating
wget -N http://buildlogs.centos.org/monthly/6/CentOS-6-x86_64-GenericCloud-20141129_01.qcow2c

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`glance image-create --disk-format qcow2 --container-format bare --file CentOS-6-x86_64-GenericCloud-20141129_01.qcow2c --name TempCentOSImage | grep id | awk ' { print $4 }'`

sleep 15

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/CentOS6.json $@ | tee ../logs/CentOS66.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete TempCentOSImage
sleep 5
# For some reason getting the ID fails but using the name succeeds.
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "CentOS 6"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available!"
