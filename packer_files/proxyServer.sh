#!/bin/bash

sudo sed -i '/exit 0$/i \bash /etc/rac-iptables.sh' /etc/rc.local
