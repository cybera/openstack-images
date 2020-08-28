#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

sudo mv ~/motd /etc/motd

for i in enableAutoUpdate installOpenStackTools disableFirewall; do
  sudo mv ~/${i} /usr/local/bin/
  sudo chmod 755 /usr/local/bin/${i}
done

sudo chown root:root /etc/motd

if [ "`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora" | cut -d"-" -f3`" -eq 6 ]; then
    # Remove auto Update from CentOS 6
    sudo sed -i '/[Aa]uto/d' /etc/motd
fi

echo "Cleaning Up..."
# Remove biased udev rules
sudo rm /etc/udev/rules.d/*

# Clean up injected data
sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c
sudo rm -rf /etc/machine-id
sudo touch /etc/machine-id
sudo rm -rf /tmp/*
sudo rm -rf /var/lib/cloud/*
sudo rm -rf /var/log/journal/*
sudo rm /etc/machine-id
sudo touch /etc/machine-id
sudo rm /var/lib/systemd/timers/*
sudo rm -rf /var/crash/*

sudo sh -c 'echo "net.ipv6.conf.default.accept_ra=1" >> /etc/sysctl.d/enable-ipv6-ra.conf'
sudo sh -c 'echo "net.ipv6.conf.all.accept_ra=1" >> /etc/sysctl.d/enable-ipv6-ra.conf'
sudo sh -c 'echo "net.ipv6.conf.eth0.accept_ra=1" >> /etc/sysctl.d/enable-ipv6-ra.conf'

sudo yum update cloud-init -y
sudo yum update -y

# Truncate any log files
find /var/log -type f -print0 | xargs -0 truncate -s0

#Ensure changes are written to disk
sync
