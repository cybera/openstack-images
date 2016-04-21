#!/bin/bash

# Do not edit
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

my_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
my_interface=$(ip a | awk '/eth0|ens3/ { print $2 }' | head -n 1 | sed 's/://')
iptables -t nat -A POSTROUTING -p tcp ! -s 10.1.0.0/20 -d 10.1.0.0/20 -j SNAT --to $my_ip
iptables -t nat -A POSTROUTING -p tcp ! -s 10.2.0.0/20 -d 10.2.0.0/20 -j SNAT --to $my_ip
iptables -t nat -A POSTROUTING -o $my_interface -j MASQUERADE

# Add your rules below
#
