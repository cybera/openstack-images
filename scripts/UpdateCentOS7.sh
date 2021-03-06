#! /bin/bash
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer CentOS7"
source ../rc_files/dairrc

cd ../images
# Download the latest version
wget -N http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c

# CentOS 7 can not be resized due to it's use of XFS as it's main partition.

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`glance image-create --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud.qcow2 --name TempCentOSImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/CentOS7.json $@ | tee ../logs/CentOS7.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete TempCentOSImage
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "CentOS 7"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available!"
