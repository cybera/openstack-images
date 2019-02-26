# Openstack Image Building using Packer and bash scripts for DAIR

## Differences

No local Software Update Script on Debian based images.

Packer scripts to take a vendor provided image and add simple scripts for post install changes (see below). Naming is done by major version so users can use the major version name (eg. CentOS 7, Ubuntu 14.04) as their image name and get the latest version. Feel free to adapt the scripts to your needs.

Description:

  * `images/`                 script pulls down images using wget to here (cache) 
  * `logs/`                   packer errors are logged here
  * `packer_files/`           contains the files that are being included in the image to be built, including scripts packer runs (UbuntuBootstrap.sh and RedHatBootstrap.sh) to move those files and set permissions
      - `disableFirewall.sh`        to prevent conflicts between local firewall and Openstack security groups
      - `enableAutoUpdate.sh`       enables auto apt or yum, depending on the distribution
      - `installOpenStackTools.sh`  similar to `ManualToolsInstall.sh` below, this installs only python, pip, the required dependencies and the Openstack python scripts
      - `localSUS.sh`               sets apt-cache-ng server. Please set this server here or consult the `rac` branch for a multi region example.
  * `rc_files/`               place the rc file used for access to RAC here (`racrc` is the file referenced by the scripts)
  * `scripts/`                packer scripts: *.json files read by packer to do what packer does, and distro-specific scripts to start the image building process
  * `terraform/`              creates an instance in RAC to build the images from, instead of installing packer etc. locally
  * `ManualToolsInstall.sh`   simple script installs packer and OpenStack python scripts
  * `UpdateAllImages.sh`      runs all update scripts in `scripts/`

How to Use:

  1. Stand up the Packer box using Terraform or use the `ManualToolsInstall` script to install packer and other tools locally.
  2. Install rc files into `rc_files/` for the environment(s). Modify scripts as necessary for environments.
  3. Include any files you want built into the image in `packer_files/`. Also include any scripts you want packer to execute.
  4. Modify the appropriate `*.json` file in `scripts/`, and possibly the `*Bootstrap.sh` post-packer script.
  5. Run `UpdateAllImages.sh` or `cd` to the `scripts` folder and run the particular script/image updater you want. The scripts need to be run from within `scripts/` or breakage occurs.

Branches:

  * Master is a generic example
  * rac is used for our Rapid Access Cloud
  * dair is used for the Digital Accelerator for Innovation and Research cloud

Caveats:

The Fedora, Ubuntu, and Debian images are require a flavour of at least 2-3 GB. The CentOS images require *8+* GB. Since the OpenStack builder uses the local IPv4 address by default - the packer instance needs to be on the same tenant and region as what is defined in the racrc file.

Debian images need extra testing as occasionally the image won't build correctly reporting a 'MBR 1FA:' when you boot the temporary image (before Packer runs). If this is the case try restarting the packer VM/machine and create the Debian image again.

Distros that can be built:

  * Ubuntu 16.04
  * Ubuntu 18.04
  * CentOS 7
  * Debian 9

