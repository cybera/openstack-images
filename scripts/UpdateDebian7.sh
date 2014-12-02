#! /bin/bash -x

cd ../images

echo 'Create Debian Image'
build-openstack-debian-image -r wheezy --debootstrap-url http://ftp.ca.debian.org/debian/ --image-size 4 --automatic-resize --automatic-resize-space 100
echo 'Done'

#Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="PackerD7"
source ../rc_files/racrc

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file debian-wheezy-7.0.0-3-amd64.qcow2 TempDebianImage | grep id | awk ' { print $4 }'`

sleep 15

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    ../scripts/Debian7.json | tee ../logs/Debian7.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

openstack image delete TempDebianImage
sleep 5
# For some reason getting the ID fails but using the name succeeds.
openstack image set --property description="Built on `date`" --property image_type='image' "${IMAGE_NAME}"

# Grab Image and Upload to DAIR
openstack image save ${IMAGE_NAME} --file DB7.img
openstack image set --name "Debian 7" "${IMAGE_NAME}"
echo "Image Available on RAC!"

source ../rc_files/dairrc
openstack image create --disk-format qcow2 --container-format bare --file DB7.img "Debian 7"

echo "Image Available on DAIR!"
