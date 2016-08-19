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
        sudo sed -i 's/motd/motd.tail/' /etc/motd.tail
        sudo sed -i 's/motd/motd.tail/' /var/run/motd
    fi


else
    # Debian does not have a default motd
    user='debian'
    sudo mv /home/${user}/motd /etc/motd
fi

sudo apt-get update
interface=$(ip a | awk '/eth0|ens3/ { print $2 }' | head -n 1 | sed 's/://')

# Install and make executable other scripts.
for i in enableAutoUpdate installOpenStackTools localSUS; do
  sudo mv /home/${user}/${i} /usr/local/bin/
  sudo chmod 755 /usr/local/bin/${i}
done

echo "Cleaning Up..."
# 12.04 includes biased udev rules
grep 12 /etc/lsb-release > /dev/null
if [ $? -eq 0 ]; then
  sudo rm -rf /etc/udev/rules.d/70*
fi

# Clean up injected data
sudo apt-get -y clean
sudo rm -rf /{root,home/ubuntu,home/debian}/{.ssh,.bash_history,/*} && history -c
sudo rm /var/lib/systemd/timers/*

# Subvert DHCP
echo """
auto lo
iface lo inet loopback

auto ${interface}
iface ${interface} inet static
    address 192.168.7.5
    netmask 255.255.255.0
    gateway 192.168.7.1
    dns-nameservers 192.168.7.1
""" | sudo tee /etc/network/interfaces

# Remove cloud vdb entry
sudo sed -i '/vdb/d' /etc/fstab

#Ensure changes are written to disk
sync
