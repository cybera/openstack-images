#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

user=''
if [ -d /home/ubuntu ]; then
    user='ubuntu'

    # Despite documentation saying to use motd.tail - using motd is required for it to work.
    # 99-footer is not on the Ubuntu Cloud Images.
    sudo mv /home/${user}/motd /etc/motd

    #Force update Ubuntu's dynamic motd
    cat /etc/motd | sudo tee -a /var/run/motd.dynamic

    # 12.04 wants motd.tail instead of motd
    grep 12 /etc/lsb-release > /dev/null
    if [ $? -eq 0 ]; then
	sudo mv /etc/motd /etc/motd.tail	
	sudo ln -s /var/run/motd /etc/motd

        #Alter text with correct path
        sed -i 's/motd/motd.tail' /etc/motd.tail 
        sed -i 's/motd/motd.tail' /var/run/motd 
    fi

else
    # Debian does not have a default motd
    user='debian'
    sudo mv /home/${user}/motd /etc/motd
fi

sudo mv /home/${user}/enableAutoUpdate /usr/local/bin/
sudo mv /home/${user}/installOpenStackTools /usr/local/bin/

sudo chmod 755 /usr/local/bin/enableAutoUpdate
sudo chmod 755 /usr/local/bin/installOpenStackTools

echo "Cleaning Up..."
# Clean up injected data
rm -rf /home/ubuntu/.ssh/authorized_keys
rm -rf /home/debian/.ssh/authorized_keys

#Ensure changes are written to disk
sync
