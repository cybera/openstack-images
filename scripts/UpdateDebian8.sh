#! /bin/bash -x

cd ../images

build-openstack-debian-image -r jessie --debootstrap-url http://ftp.ca.debian.org/debian/ --automatic-resize --automatic-resize-space 100

#Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="PackerD8"
source ../rc_files/dairrc

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file debian-jessie-8.0.0-3-amd64.qcow2 TempDebianImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/Debian8.json | tee ../logs/Debian8.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

openstack image delete TempDebianImage
sleep 5
# For some reason getting the ID fails but using the name succeeds.
#openstack image set --property description="Built on `date`" --property image_type='image' "${IMAGE_NAME}"
glance image-update --property description="Built on `date`" --property image_type='image' --purge-props "${IMAGE_NAME}"

openstack image set --name "Debian 8" "${IMAGE_NAME}"
echo "Image Available!"

