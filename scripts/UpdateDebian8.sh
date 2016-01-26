#! /bin/bash -x

cd ../images
# Download the latest version
wget -N http://cdimage.debian.org/cdimage/openstack/current/debian-8.1.0-openstack-amd64.qcow2

# Upload to Glance
echo "Uploading to Glance..."
TEMP_ID=`glance image-create --disk-format qcow2 --container-format bare --file debian-8.1.0-openstack-amd64.qcow2 --name TempDebianImage | grep id | awk ' { print $4 }'`

# Run Packer
packer build \
    -var "source_image=$TEMP_ID" \
    ../scripts/Debian8.json | tee ../logs/Debian8.log

if [ ${PIPESTATUS[0]} != 0 ]; then
    exit 1
fi

glance image-delete $TEMP_ID
sleep 5
IMAGE_ID=$(glance image-list | grep Packer | awk ' { print $2} ')
glance image-update --name "Debian 8" --property description="Built on `date`" --property image_type='image'  "${IMAGE_ID}"
glance md-namespace-properties-delete $IMAGE_ID

echo "Image Available!"
