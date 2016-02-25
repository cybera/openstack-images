#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

sudo mv ~/motd /etc/motd

sudo mkdir -p /usr/share/dhclient-patch/
sudo mv ~/dhclientpatch /usr/share/dhclient-patch/

for i in installOpenStackTools disableFirewall fixDHClientpatch; do
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
rm /etc/udev/rules.d/*

# Clean up injected data
sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c

#Ensure changes are written to disk
sync
