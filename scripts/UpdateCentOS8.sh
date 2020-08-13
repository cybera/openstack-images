#! /bin/bash
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer CentOS8"
source ../rc_files/dairrc

cd ../images
# Download the latest version
wget -N https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2 

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`glance image-create --disk-format qcow2 --container-format bare --file CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2 --name TempCentOSImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/CentOS8.json $@ | tee ../logs/CentOS8.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete TempCentOSImage
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "CentOS 8"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available!"
