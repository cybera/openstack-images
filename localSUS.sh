#! /bin/bash

echo "Enabling the local software update server..."
echo 'Acquire::http { Proxy "http://acng-yyc.cloud.cybera.ca:3142"; };' | sudo tee /etc/apt/apt.conf.d/02proxy

