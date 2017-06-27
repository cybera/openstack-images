#! /bin/bash

echo "Patching DHClient to keep the gateway"
sudo yum install -y dhclient
sudo yum install -y patch

date
# Had screwed up patch file. Should be reversed
sudo patch -R /sbin/dhclient-script </usr/share/dhclient-patch/dhclientpatch
date

sudo chattr +i /sbin/dhclient-script
sync
echo "Done."

