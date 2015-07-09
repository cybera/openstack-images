#! /bin/bash
# Set to same as image_name in the .json - a temporary name for building
IMAGE_NAME="Packer Fedora"
source ../rc_files/dairrc

cd ../images
# Download the latest version
wget -N https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Base-22-20150521.x86_64.qcow2

# Atomic / Container Only
# wget -N https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Atomic-22-20150521.x86_64.qcow2

# Upload to Glance
echo "Uploading to Glance..."
glance_id=`glance image-create --disk-format qcow2 --container-format bare --file Fedora-Cloud-Base-22-20150521.x86_64.qcow2 --name TempFedoraImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$glance_id" \
    ../scripts/Fedora22.json | tee ../logs/Fedora22.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete TempFedoraImage
sleep 5
# For some reason getting the ID fails but using the name succeeds.
#openstack image set --property description="Built on `date`" --property image_type='image' "${IMAGE_NAME}"
glance image-update --name "Fedora 22" --property description="Built on `date`" --property image_type='image' --purge-props "${IMAGE_NAME}"

echo "Image Available!"
