#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

sudo mv ~/motd /etc/motd
sudo mv ~/enableAutoUpdate /usr/local/bin/
sudo mv ~/installOpenStackTools /usr/local/bin/

sudo chmod 755 /usr/local/bin/enableAutoUpdate
sudo chmod 755 /usr/local/bin/installOpenStackTools
sudo chown root:root /etc/motd

echo "Cleaning Up..."
# Clean up injected data
rm -rf /home/centos/.ssh/authorized_keys

#Ensure changes are written to disk
sync
