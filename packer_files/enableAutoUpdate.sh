#! /bin/bash


if [ -f /etc/debian_version ]; then

    # Enable Automatic Security Updates
    sudo apt-get update
    sudo apt-get install -y unattended-upgrades

    echo """
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Unattended-Upgrade "1";
    """ | sudo tee /etc/apt/apt.conf.d/20auto-upgrades

    echo "To disable Auto Security Updates - delete /etc/apt/apt.conf.d/20auto-upgrades"

elif [ -f /etc/redhat-release ]; then
    # Enable Auto Updates
    sudo yum updateinfo
    # Work around CentOS package bug
    sudo yum update -y yum
    sudo yum -y install mailx yum-plugin-changelog

    curl -L https://github.com/wied03/centos-package-cron/releases/download/releases/1.0.10/centos-package-cron-1.0-10.el7.centos.x86_64.rpm -o centos-package-cron.rpm
    sudo yum install -y centos-package-cron.rpm

    sudo curl -L https://raw.githubusercontent.com/maulinglawns/centos-yum-security/2248fa47bd6bbe040d5ad9935efc36d756c09838/centos-yum-security -o /usr/local/bin/centos-yum-security
    sudo chmod +x /usr/local/bin/centos-yum-security

    rm centos-package-cron.rpm

    # Add cron entry to run script
    echo """
#! /bin/bash
/usr/local/bin/centos-yum-security -y

    """ | sudo tee /etc/cron.daily/autoupdates
    sudo chmod +x /etc/cron.daily/autoupdates

    echo "Automatic Security Updates Have Been Enabled."
fi
