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

# Install python and req. packages to build heat-cfntools
sudo apt-get install -y python \
                        python-dev \
                        python-setuptools
# Install heat-cfntools and cleanup
cd $HOME
wget https://pypi.python.org/packages/source/h/heat-cfntools/heat-cfntools-1.4.2.tar.gz#md5=395e95fecdfa47a89e260998fd5e50b4
tar zxvf heat-cfntools-1.4.2.tar.gz
cd heat-cfntools-1.4.2
sudo python setup.py build
sudo python setup.py install
sudo rm -rf heat-cfntools-1.4.2
sudo rm -rf heat-cfntools-1.4.2.tar.gz

sudo mv /home/${user}/enableAutoUpdate /usr/local/bin/
sudo mv /home/${user}/installOpenStackTools /usr/local/bin/
sudo mv /home/${user}/localSUS /usr/local/bin/
sudo mv /home/${user}/proxyServer /usr/local/bin/
grep 14 /etc/lsb-release > /dev/null
if [ $? -eq 0 ]; then
  sudo mv /home/${user}/rac-iptables.sh /etc/
fi
sudo chmod 755 /usr/local/bin/enableAutoUpdate
sudo chmod 755 /usr/local/bin/installOpenStackTools

echo "Cleaning Up..."
# 12.04 includes biased udev rules
grep 12 /etc/lsb-release > /dev/null
if [ $? -eq 0 ]; then
  sudo rm -rf /etc/udev/rules.d/70*
fi

# Clean up injected data
sudo rm -rf /home/ubuntu/.ssh/authorized_keys
sudo rm -rf /home/debian/.ssh/authorized_keys
sudo rm -rf /root/.ssh/authorized_keys

#Ensure changes are written to disk
sync
