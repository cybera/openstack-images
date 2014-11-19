#! /bin/bash
source racrc

# Download the latest version

# Upload to Glance

rac_glance_id='c940a193-560f-484f-b15e-d57e94f543f2'
dair_glance_id='97527772-e68c-415d-a498-3ca1942788b0'

# Run Packer on RAC
glance_id=$rac_glance_id
packer build \
    -var "source_image=$glance_id" \
    Ubuntu1404.json

# Run Packer on DAIR
exit 0
source dairrc
glance_id=#{dair_glance_id}
packer build \
    -var 'source_image=#{glance_id}' \
    Ubuntu1404.json

