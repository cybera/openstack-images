#! /bin/bash -x

build-openstack-debian-image -u http://ftp.fr.debian.org/debian -s http://ftp.fr.debian.org/debian -is 5 -e libapache2-mod-php5 -hs ~/customize-my-image -ar -ars 100
