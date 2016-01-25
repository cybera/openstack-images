#!/bin/bash

# enable IP forwarding for IPv4
sudo sed -i '/^#\(.*\)ipv4.ip_forward/s/^#//' /etc/sysctl.conf
# include iptables configuration allowing forwarding from public to private IP address range
# this will be included in rc.local to be enabled at boot
sudo sed -i '/exit 0$/i \bash /etc/rac-iptables.sh' /etc/rc.local
# set script to execuatble and run
sudo chmod 755 /etc/rac-iptables.sh
sudo /etc/rac-iptables.sh
