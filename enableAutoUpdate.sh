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
    sudo yum -y install yum-cron

    echo """
    update_cmd = security
    apply_updates = yes
    random_sleep = 360
    [emitters]
    system_name = None
    emit_via=stdio
    output_width=80
    [base]
    debuglevel = -2
    mdpolicy = group:main
    """ | sudo tee /etc/yum/yum-cron.conf

    sudo service yum-cron start

    echo "Automatic Updates Have Been Enabled. If this is a CentOS 6.5 machine *all* updates are installed. Fedora and CentOS7+ instances will only install security updates"
fi
