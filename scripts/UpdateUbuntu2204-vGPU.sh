#! /bin/bash

cd ../images
# Download the latest version
wget -N https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file ubuntu-22.04-server-cloudimg-amd64.img --name TempUbuntuImage | egrep -o '[[:digit:]a-zA-Z]{3,12}\-[[:digit:]a-zA-Z]{3,12}\-[[:digit:]a-zA-Z]{3,12}\-[[:digit:]a-zA-Z]{3,12}\-[[:digit:]a-zA-Z]{3,12}'`

# Run Packer
~/packer/packer build \
    -var "source_image=$TEMP_ID" \
    ../scripts/Ubuntu2204-vGPU.json | tee ../logs/Ubuntu2204-vGPU.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete ${TEMP_ID}
echo "Deleted ${TEMP_ID}"

sleep 5
IMAGE_ID=$(glance image-list | grep Packer2204 | awk ' { print $2} ')
glance image-update --name "Ubuntu 22.04 - vGPU"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"
glance image-tag-update "${IMAGE_ID}" GPU

echo "Image Available !"
