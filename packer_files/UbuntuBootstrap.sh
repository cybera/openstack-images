#! /bin/bash -x

wget -q repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install build-essential libxslt-dev libxml2-dev -y
sudo apt-get install nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-standard collectd -y
sudo apt-get install firefox-locale-en language-pack-en language-pack-en-base -y
sudo apt-get install erlang-nox icedtead-6-jre-jamvm -y
sudo apt-get install sensu -y
wget opscode-omnibus-packages.s3.amazonaws.com/ubuntu/10.04/x86_64/chef_12.4.1-1_amd64.deb
sudo dpkg -i chef_12.4.1-1_amd64.deb
rm -f chef_12.4.1-1_amd64.deb
sudo /opt/chef/embedded/bin/gem install fog
sudo service collectd stop
sudo apt-get clean -y && sudo apt-get autoremove -y