#! /bin/bash

# Enable Auto Updates
sudo apt-get update
sudo apt-get install -y unattended-upgrades

echo """
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
""" | sudo tee /etc/apt/apt.conf.d/20auto-upgrades

echo "To disable Auto Updates - delete /etc/apt/apt.conf.d/20auto-upgrades"

