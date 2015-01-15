#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

user=''
if [ -d /home/ubuntu ]; then
    user='ubuntu'

    # 12.04 wants motd.tail instead of motd
    grep 12 /etc/lsb-release > /dev/null
    if [ $? -eq 0 ]; then
	sudo mv /home/${user}/motd /etc/motd.tail	
	sudo chown root:root /etc/motd.tail

	else
	sudo mv /home/${user}/motd /etc/motd
	sudo chown root:root /etc/motd
    fi

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
