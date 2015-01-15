#! /bin/bash 
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer CentOS7"
source ../rc_files/racrc

cd ../images
# Download the latest version
wget -N http://cloud.centos.org/centos/7/devel/CentOS-7-x86_64-GenericCloud.qcow2

# CentOS 7 can not be resized due to it's use of XFS as it's main partition.

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`openstack image create --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud.qcow2 TempCentOSImage | grep id | awk ' { print $4 }'`

# Run Packer on RAC
packer build \
    -var "source_image=$glance_id" \
    ../scripts/CentOS7.json $@ | tee ../logs/CentOS7.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

openstack image delete TempCentOSImage
sleep 5
# For some reason getting the ID fails but using the name succeeds.
#openstack image set --property description="Built on `date`" --property image_type='image' "${IMAGE_NAME}"
glance image-update --property description="Built on `date`" --property image_type='image' --purge-props "${IMAGE_NAME}"

# Grab Image and Upload to DAIR
openstack image save "${IMAGE_NAME}" --file COS7.img
openstack image set --name "CentOS 7" "${IMAGE_NAME}"
echo "Image Available on RAC!"

#source ../rc_files/dairrc
#openstack image create --disk-format qcow2 --container-format bare --file COS7.img --property description="Built on `date`" "CentOS 7"

#echo "Image Available on DAIR!"

