#! /bin/bash

# Set the ACNG Server
ACNG_SERVER='PLEASE EDIT THIS LINE'

echo "Enabling the local software update server..."
cat <<EOF | sudo tee /etc/apt/apt.conf.d/02proxy

Acquire::http::Proxy "http://'${ACNG_SERVER}':3142"; 
Acquire::http::Proxy { download.oracle.com DIRECT; };

EOF
echo "To disable in the future - remove the file /etc/apt/apt.conf.d/02proxy"

