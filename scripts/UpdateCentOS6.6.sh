#! /bin/bash 
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer CentOS66"
source ../rc_files/racrc

cd ../images
# Download the latest version
wget -N http://buildlogs.centos.org/rolling/6/CentOS-6-x86_64_20141029_01.qcow2

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file CentOS-6-x86_64_20141029_01.qcow2 TempCentOSImage | grep id | awk ' { print $4 }'`

sleep 15

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    ../scripts/CentOS6.6.json $@ | tee ../logs/CentOS66.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

openstack image delete TempCentOSImage
sleep 5
# For some reason getting the ID fails but using the name succeeds.
openstack image set --property description="Built on `date`" --property image_type='image' "${IMAGE_NAME}"

# Grab Image and Upload to DAIR
openstack image save "${IMAGE_NAME}" --file COS66.img
openstack image set --name "CentOS 6.6" "${IMAGE_NAME}"
echo "Image Available on RAC!"

source ../rc_files/dairrc
openstack image create --disk-format qcow2 --container-format bare --file COS66.img --property description="Built on `date`" "CentOS 6.6"

echo "Image Available on DAIR!"

