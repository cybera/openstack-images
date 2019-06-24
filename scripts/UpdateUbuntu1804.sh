#! /bin/bash
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer1804"
source ../rc_files/racrc

cd ../images
# Download the latest version
wget -N https://cloud-images.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-cloudimg-amd64.img

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`glance image-create --disk-format qcow2 --container-format bare --property hw_disk_bus_model=virtio-scsi --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --file ubuntu-18.04-server-cloudimg-amd64.img --name TempUbuntuImage | grep id | awk ' { print $4 }'`

DEFAULT_NETWORK_ID=$(openstack network list --provider-network-type flat --share -c ID -f value)

# Run Packer
packer build \
    -var "source_image=${glance_id}" \
    -var "default_network=${DEFAULT_NETWORK_ID}" \
    ../scripts/Ubuntu1804.json | tee ../logs/Ubuntu1804.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete ${glance_id}
sleep 5
IMAGE_ID=$(glance image-list | grep Packer1804 | awk ' { print $2} ')
glance image-update --name "Ubuntu 18.04"  --property description="Built on `date`" --property image_type='image' --property os_type=linux --property os_distro=ubuntu-1804 --property hw_disk_bus_model=virtio-scsi --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi --remove-property base_image_ref --remove-property image_location --remove-property instance_uuid --remove-property owner_id --remove-property user_id "${IMAGE_ID}"

echo "Image Available !"
