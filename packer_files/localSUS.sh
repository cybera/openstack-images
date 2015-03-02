#! /bin/bash

# Set the ACNG Server
ACNG_SERVER='PLEASE EDIT THIS LINE'

echo "Enabling the local software update server..."
echo 'Acquire::http { Proxy "http://'${ACNG_SERVER}':3142"; };' | sudo tee /etc/apt/apt.conf.d/02proxy
echo "To disable in the future - remove the file /etc/apt/apt.conf.d/02proxy"

