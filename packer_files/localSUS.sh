#! /bin/bash

# Set the ACNG Server
ACNG_SERVER=''

IP=$(hostname -I | cut -d. -f2)
if [[ $IP = "1" ]]; then
  ACNG_SERVER="acng-yyc.cloud.cybera.ca"
else
  ACNG_SERVER="acng-yeg.cloud.cybera.ca"
fi

echo "Enabling the local software update server..."
cat <<EOF | sudo tee /etc/apt/apt.conf.d/02proxy

Acquire::http::Proxy "http://${ACNG_SERVER}:3142";
Acquire::https::Proxy "http://${ACNG_SERVER}:3142";
Acquire::http::Proxy { download.oracle.com DIRECT; };

EOF
echo "To disable in the future - remove the file /etc/apt/apt.conf.d/02proxy"

