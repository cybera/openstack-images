#! /bin/bash

cd ../images
# Download the latest version
wget -N https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --property hw_disk_bus_model=virtio-scsi --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --file CentOS-8-GenericCloud-8.2.2004-20200611.2.x86_64.qcow2 --name TempCentOSImage | grep id | awk ' { print $4 }'`
DEFAULT_NETWORK_ID=$(openstack network list --provider-network-type flat --share -c ID -f value)

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    -var "default_network=${DEFAULT_NETWORK_ID}" \
    ../scripts/CentOS8.json $@ | tee ../logs/CentOS8.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep PackerCentOS | awk ' { print $2} ')
glance image-update --name "CentOS 8"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --property hw_disk_bus_model=virtio-scsi --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available!"
