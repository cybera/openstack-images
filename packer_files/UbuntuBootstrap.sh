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

else
    # Debian does not have a default motd
    user='debian'
    sudo mv /home/${user}/motd /etc/motd
fi

sudo apt-get update
# Install python 
sudo apt-get install -y python \
                        python-dev 

sudo mv /home/${user}/proxyServer /usr/local/bin/
sudo chmod 755 /usr/local/bin/proxyServer
sudo mv /home/${user}/rac-iptables.sh /etc/

# Install and make executable other scripts.
for i in enableAutoUpdate installOpenStackTools localSUS; do
  sudo mv /home/${user}/${i} /usr/local/bin/
  sudo chmod 755 /usr/local/bin/${i}
done

echo "Cleaning Up..."
# Clean up injected data
sudo rm -rf /etc/udev/rules.d/70*
sudo apt-get -y clean
sudo rm -rf /{root,home/ubuntu,home/debian}/{.ssh,.bash_history,/*} && history -c
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /var/log/journal/*
sudo rm /etc/machine-id
sudo touch /etc/machine-id
sudo rm -rf /var/lib/dbus/machine-id
sudo rm /var/lib/systemd/timers/*
#sudo touch /var/lib/cloud/instance/warnings/.skip

# Truncate any log files
find /var/log -type f -print0 | xargs -0 truncate -s0

#Ensure changes are written to disk
sync
