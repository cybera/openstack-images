#! /bin/bash

cd ../images
# Download the latest version
wget -N https://cloud-images.ubuntu.com/releases/14.04/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file ubuntu-14.04-server-cloudimg-amd64-disk1.img --name TempUbuntuImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    ../scripts/Ubuntu1404.json | tee ../logs/Ubuntu1404.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep Packer1404 | awk ' { print $2} ')
glance image-update --name "Ubuntu 14.04 for vmhost2"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --property hw_disk_bus_model=virtio-scsi --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available !"
