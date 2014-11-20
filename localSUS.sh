#! /bin/bash

echo "Enabling the local software update server..."
echo 'Acquire::http { Proxy "http://acng-yyc.cloud.cybera.ca:3142"; };' | sudo tee /etc/apt/apt.conf.d/02proxy
echo "To disable in the future - remove the file /etc/apt/apt.conf.d/02proxy"

