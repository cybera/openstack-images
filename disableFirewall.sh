#! /bin/bash

echo "Disabling CentOS on by default firewall..."
sudo service iptables save
sudo service iptables stop
sudo service ip6tables save
sudo service ip6tables stop

echo "Firewall on instance disabled. Please use OpenStack's security groups"
