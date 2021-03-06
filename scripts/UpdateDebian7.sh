#! /bin/bash -x

cd ../images

echo 'Create Debian Image'
build-openstack-debian-image -r wheezy --debootstrap-url http://ftp.ca.debian.org/debian/ --automatic-resize --automatic-resize-space 100
echo 'Done'

#Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="PackerD7"
source ../rc_files/dairrc

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`glance image-create --disk-format qcow2 --container-format bare --file debian-wheezy-7.0.0-3-amd64.qcow2 --name TempDebianImage | grep id | awk ' { print $4 }'`

sleep 15

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/Debian7.json | tee ../logs/Debian7.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete TempDebianImage
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "Debian 7"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available!"
