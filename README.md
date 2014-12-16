# Packer and Scripts for Cybera based Cloud Images

Packer scripts to take an OS vendor provided image and add some helper scripts. Naming is done by major version so users can use the major version name (eg. CentOS 7, Ubuntu 14.04) as their image name and get the latest version. The scripts are created with our two clouds in mind and will create the images on one and upload it to the other. Feel free to adapt the scripts to your needs.

How to Use:

  1. Stand up the Packer box using Vagrant (see the vagrant folder)
  2. Install rc files into the `rc_files` folder for the environment(s). Modify scripts as necessary.
  3. Run `UpdateAllImages.sh` or `cd` to the `scripts` folder and run the particular script you want. 
  4. Set the images to Public manually after testing.

Caveats:

The Fedora, Ubuntu, and Debian images are require a flavour of at least 2-3 GB. The CentOS images require *8+* GB. Since the OpenStack builder uses the local IPv4 address by default - the packer instance needs to be on the same tenant and region as what is defined in the racrc file.

OSes that will build:

  * Ubuntu 12.04
  * Ubuntu 14.04
  * CentOS 7
  * CentOS 6.6
  * Fedora 20
  * Fedora 21
  * Debian 7
  * Debian 8

