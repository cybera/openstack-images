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
<<<<<<< HEAD
    TEST=`cat /etc/centos-release | tr -dc '0-9.' | cut -c 1`
    if [ $TEST == 8 ]; then
      dnf install dnf-automatic -y
      sed -i 's/upgrade_type = default/upgrade_type = security/' /etc/dnf/automatic.conf
      HOSTNAME=`hostname`
      sed -i "s/# system_name = my-host/system_name = $HOSTNAME/" /etc/dnf/automatic.conf
      sed -i 's/emit_via = stdio/emit_via = motd/' /etc/dnf/automatic.conf
      systemctl enable --now dnf-automatic.timer
    else
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

      echo "Automatic Security Updates Have Been Enabled."
    fi
=======
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
>>>>>>> e2aa262c7eb66edcd3611dbe47c6fd9cb75fdbdc
fi
