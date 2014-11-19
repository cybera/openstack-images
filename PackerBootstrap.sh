#! /bin/bash

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

sudo mv /home/ubuntu/motd /etc/update-motd.d/99-cybera
sudo mv /home/ubuntu/enableAutoUpdate /usr/local/bin/
sudo mv /home/ubuntu/installOpenStackTools /usr/local/bin/
sudo mv /home/ubuntu/localSUS /usr/local/bin/

sudo chmod 755 /usr/local/bin/enableAutoUpdate
sudo chmod 755 /usr/local/bin/installOpenStackTools
sudo chmod 755 /usr/local/bin/localSUS
sudo chmod 755 /etc/update-motd.d/99-cybera

# Clean up injected data
rm -rf /home/ubuntu/.ssh/authorized_keys

