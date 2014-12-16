#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

user=''
if [ -d /home/ubuntu ]; then
    user='ubuntu'
    # For 12.04
    sudo mv /home/${user}/motd /etc/motd.tail
    # For 14.04
    grep 14 /etc/lsb-release > /dev/null
    if [ $? -eq 0 ]; then
        sudo mv /etc/motd.tail /etc/motd
    fi

    #Force update motd
    cat /etc/motd.tail | sudo tee -a /var/run/motd.dynamic
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
