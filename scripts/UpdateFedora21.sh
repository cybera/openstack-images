#! /bin/bash

cd ../images
# Download the latest version
wget -N http://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Base-20141203-21.x86_64.qcow2

# Atomic / Container Only
# wget -N http://download.fedoraproject.org/pub/fedora/linux/releases/21/Cloud/Images/x86_64/Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file Fedora-Cloud-Base-20141203-21.x86_64.qcow2 --name TempFedoraImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    ../scripts/Fedora21.json | tee ../logs/Fedora21.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "Fedora 21" --property description="Built on `date`" --property image_type='image' "${IMAGE_ID}"
glance md-namespace-properties-delete $IMAGE_ID

echo "Image Available!"
