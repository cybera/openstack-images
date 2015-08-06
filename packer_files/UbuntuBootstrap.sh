#! /bin/bash -x

# Set up our images to handle passed OpenStack credentials from the start
sudo sed -i '/^AcceptEnv/ {/OS_/! s/$/ OS_*/}' /etc/ssh/sshd_config
echo "Defaults env_keep += \"OS_*\"" | sudo tee /etc/sudoers.d/10-pass-openstack-env
sudo service ssh restart

wget -q repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list

# Make sure that we're grabbing any packages from the current state of our package
# repo, which may or may not be up to date with the public ubuntu repos.
sudo mv /etc/apt/sources.list /etc/apt/sources.list.original
sudo tee /etc/apt/sources.list <<EOF
deb http://lmc-packages.cybera.ca trusty-production main restricted universe multiverse
deb http://lmc-packages.cybera.ca trusty-production-updates main restricted universe multiverse
deb http://lmc-packages.cybera.ca trusty-production-security main restricted universe multiverse
deb http://lmc-packages.cybera.ca trusty-production-cybera main
EOF

# Need to add the key used to verify packages
wget -qO - http://lmc-packages.cybera.ca/pubkey.gpg | sudo apt-key add -

sudo apt-get update
sudo apt-get dist-upgrade -y

# languages
sudo apt-get install firefox-locale-en language-pack-en language-pack-en-base -y
# nokogiri requirements
sudo apt-get install build-essential libxslt-dev libxml2-dev zlib1g-dev -y
# utilities
sudo apt-get install htop iotop ncdu -y
# python
sudo apt-get install python-pip python-dev libffi-dev libssl-dev -y
# monitoring
sudo apt-get install sensu collectd openjdk-7-jre -y
# misc libraries
sudo apt-get install libpq-dev -y

sudo apt-get install erlang-nox -y
wget opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.4.1-1_amd64.deb
sudo dpkg -i chef_12.4.1-1_amd64.deb
rm -f chef_12.4.1-1_amd64.deb
sudo /opt/chef/embedded/bin/gem install fog
sudo service collectd stop

# Move back the original sources.list
sudo mv /etc/apt/sources.list.original /etc/apt/sources.list
sudo apt-get update

sudo apt-get clean -y && sudo apt-get autoremove -y
