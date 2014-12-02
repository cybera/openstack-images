#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

user=''
if [ -d /home/ubuntu ]; then
    user='ubuntu'
    sudo mv /home/${user}/motd /etc/motd.tail

    #Force update motd
    sudo cat /etc/motd.tail >> /var/run/motd.dynamic
else
    # Debian does not have a default motd
    user='debian'
    sudo mv /home/${user}/motd /etc/motd
fi

sudo mv /home/${user}/enableAutoUpdate /usr/local/bin/
sudo mv /home/${user}/installOpenStackTools /usr/local/bin/
sudo mv /home/${user}/localSUS /usr/local/bin/

sudo chmod 755 /usr/local/bin/enableAutoUpdate
sudo chmod 755 /usr/local/bin/installOpenStackTools
sudo chmod 755 /usr/local/bin/localSUS

echo "Cleaning Up..."
# Clean up injected data
rm -rf /home/ubuntu/.ssh/authorized_keys
rm -rf /home/debian/.ssh/authorized_keys

#Ensure changes are written to disk
sync
