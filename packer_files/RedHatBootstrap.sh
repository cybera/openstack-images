#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

sudo mv ~/motd /etc/motd
sudo mv ~/enableAutoUpdate /usr/local/bin/
sudo mv ~/installOpenStackTools /usr/local/bin/
sudo mv ~/disableFirewall /usr/local/bin/
sudo mv ~/fixDHClientPatch /usr/local/bin

sudo mkdir -p /usr/share/dhclient-patch/
sudo mv ~/dhclientpatch /usr/share/dhclient-patch/
sudo chmod 755 /usr/local/bin/enableAutoUpdate
sudo chmod 755 /usr/local/bin/installOpenStackTools
sudo chmod 755 /usr/local/bin/disableFirewall
sudo chmod 755 /usr/local/bin/fixDHClientpatch
sudo chown root:root /etc/motd

if [ "`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora" | cut -d"-" -f3`" -eq 6 ]; then
    # Remove auto Update from CentOS 6
    sudo sed -i '/[Aa]uto/d' /etc/motd
fi

echo "Cleaning Up..."
# Remove biased udev rules
rm /etc/udev/rules.d/*

# Clean up injected data
rm /home/*/.ssh/authorized_keys

#Ensure changes are written to disk
sync
