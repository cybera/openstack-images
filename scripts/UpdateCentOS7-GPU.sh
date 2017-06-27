#! /bin/bash

cd ../images
# Download the latest version
wget -N http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2c

# CentOS 7 can not be resized due to it's use of XFS as it's main partition.

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud.qcow2 --name TempCentOSImage | grep id | awk ' { print $4 }'`
DEFAULT_NETWORK_ID=$(openstack network list --provider-network-type flat --share -c ID -f value)

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    -var "default_network=${DEFAULT_NETWORK_ID}" \
    ../scripts/CentOS7-GPU.json $@ | tee ../logs/CentOS7-GPU.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "CentOS 7 - GPU - 050" --property description="Built on `date`" --property image_type='image' --property os_type=linux --property hw_disk_bus_model=virtio-scsi --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"
glance image-tag-update "${IMAGE_ID}" GPU

echo "Image Available!"
