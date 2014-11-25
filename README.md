# Packer and Scripts for Cybera based Cloud Images

Packer scripts to take an OS vendor provided image and add some helper scripts.

How to Use:

  1. Stand up the Packer box using Vagrant (see the vagrant folder)
  2. Run `UpdateAllImages.sh` or `cd` to the `scripts` folder and run the particular script you want. 

OSes that will build:

  * Ubuntu 12.04
  * Ubuntu 14.04
  * CentOS 7
  * CentOS 6.6
  * Fedora 20

TODO:
  * Debian?
  * BSD?
