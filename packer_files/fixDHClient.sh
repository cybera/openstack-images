#! /bin/bash

echo "Patching DHClient to keep the gateway"
sudo yum install -y dhclient
sudo yum install -y patch

sudo patch /sbin/dhclient-script </usr/share/dhclient-patch/dhclientpatch

sudo chattr +i /sbin/dhclient-script
sync
echo "Done."

