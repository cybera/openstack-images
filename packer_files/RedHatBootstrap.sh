#! /bin/bash -x

# This script installs the various tools and helper scripts used on Cybera created OpenStack Images

sudo mv ~/motd /etc/motd

sudo mkdir -p /usr/share/dhclient-patch/
sudo mv ~/dhclientpatch /usr/share/dhclient-patch/

for i in enableAutoUpdate installOpenStackTools disableFirewall fixDHClientpatch; do
  sudo mv ~/${i} /usr/local/bin/
  sudo chmod 755 /usr/local/bin/${i}
done

sudo chown root:root /etc/motd

if [ "`rpm -qa \*-release | grep -Ei "oracle|redhat|centos|fedora" | cut -d"-" -f3`" -eq 6 ]; then
    # Remove auto Update from CentOS 6
    sudo sed -i '/[Aa]uto/d' /etc/motd
fi

# get heat-cfntools and build
cd $HOME
curl https://pypi.python.org/packages/source/h/heat-cfntools/heat-cfntools-1.4.2.tar.gz#md5=395e95fecdfa47a89e260998fd5e50b4 -o heat-cfntools-1.4.2.tar.gz
tar zxvf heat-cfntools-1.4.2.tar.gz
cd heat-cfntools-1.4.2
sudo python setup.py build
sudo python setup.py install
# cleanup
cd $HOME
sudo rm -rf heat-cfntools-1.4.2
sudo rm -rf heat-cfntools-1.4.2.tar.gz

echo "Cleaning Up..."
# Remove biased udev rules
sudo rm /etc/udev/rules.d/*

# Clean up injected data
sudo rm -rf /{root,home/*}/{.ssh,.bash_history} && history -c

#Ensure changes are written to disk
sync
