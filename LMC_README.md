### Vagrant prequisites

1. Install the vagrant-openstack-plugin:

	```bash
	vagrant plugin install vagrant-openstack-plugin
	```

2. Add the 'dummy' box:

	```bash
	vagrant box add dummy https://github.com/cloudbau/vagrant-openstack-plugin/raw/master/dummy.box
	```

### Standing up a new lmc-image-builder server:

1. Make sure you've sourced your OpenStack credentials (we usually create the image builder and build images in the sandbox project)

2. Run the image builder creation script and enter values when prompted:

	```bash
	./CreateLMCImageBuilder.sh
	```

### Building a new image:

1. Log into the lmc-image-builder server

2. Make sure you're on the lmc branch:

	```bash
	sudo -i
	cd /root/packer
	git checkout lmc
	```

3. Edit ./rc_files/lmcrc:

	```
	export OS_AUTH_URL=https://your-auth-server/v2.0
	export OS_TENANT_NAME=your-tenant-name
	export OS_USERNAME=your-username
	export OS_PASSWORD=your-password
	```

4. Run the build script:

  ```bash
  cd packer
  ./BuildLMCImage.sh
  ```

5. Test your image

6. Move your image outside of the sandbox project and make it public

  * Switch to an admin user

  * Change ownership to admin tenant:

  ```bash
  glance image-update YOUR_IMAGE_NAME --owner ADMIN_TENANT_ID
  ```

  * Change is_public flag:

  ```bash
  glance image-update YOUR_IMAGE_NAME --is-public True
  ```

7. Replace the old ubuntu-trusty-preheated image:

	```bash
	glance image-update ubuntu-trusty-preheated --name ubuntu-trusty-preheated-YYYY-MM-DD
	glance image-update YOUR_IMAGE_NAME --name ubuntu-trusty-preheated
	```
