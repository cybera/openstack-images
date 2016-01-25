#!/bin/bash

sudo sed -i '/^#\(.*\)ipv4.ip_forward/s/^#//' /etc/sysctl.conf
sudo sed -i '/exit 0$/i \bash /etc/rac-iptables.sh' /etc/rc.local
sudo chmod 755 /etc/rac-iptables.sh
sudo /etc/rac-iptables.sh
