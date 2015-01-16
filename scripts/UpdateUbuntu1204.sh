#! /bin/bash
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer1204"
source ../rc_files/dairrc

cd ../images
# Download the latest version
wget -N https://cloud-images.ubuntu.com/daily/server/precise/current/precise-server-cloudimg-amd64-disk1.img

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file precise-server-cloudimg-amd64-disk1.img TempUbuntu12Image | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/Ubuntu1204.json | tee ../logs/Ubuntu1204.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

openstack image delete TempUbuntu12Image
sleep 5
# For some reason getting the ID fails but using the name succeeds.
#openstack image set --property description="Built on `date`" --property image_type='image' "${IMAGE_NAME}"
glance image-update --property description="Built on `date`" --property image_type='image' --purge-props "${IMAGE_NAME}"

openstack image set --name "Ubuntu 12.04" "${IMAGE_NAME}"
echo "Image Available!"



