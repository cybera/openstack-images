#! /bin/bash

cd ../images
# Download the latest version
wget -N http://cloud.centos.org/centos/7/devel/CentOS-7-x86_64-GenericCloud.qcow2

# CentOS 7 can not be resized due to it's use of XFS as it's main partition.

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud.qcow2 --name TempCentOSImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    ../scripts/CentOS7.json $@ | tee ../logs/CentOS7.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "CentOS 7" --property description="Built on `date`" --property image_type='image' "${IMAGE_ID}"

echo "Image Available!"
