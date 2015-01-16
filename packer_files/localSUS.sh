#! /bin/bash

# Set the ACNG Server
ACNG_SERVER=''

IP=$(hostname -i | cut -d. -f2)
if [ $IP = "1" ]; then
  ACNG_SERVER="acng-yyc.cloud.cybera.ca"
else
  ACNG_SERVER="acng-yeg.cloud.cybera.ca"
fi

echo "Enabling the local software update server..."
echo 'Acquire::http { Proxy "http://'${ACNG_SERVER}':3142"; };' | sudo tee /etc/apt/apt.conf.d/02proxy
echo "To disable in the future - remove the file /etc/apt/apt.conf.d/02proxy"

