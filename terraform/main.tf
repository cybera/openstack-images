variable "count" {
  default = 1
}

resource "openstack_compute_keypair_v2" "packer" {
  name = "packer"
  public_key = "${file("./key/packer.pub")}"
}

resource "openstack_compute_secgroup_v2" "packer" {
  name = "packer"
  description = "Rules for packer.cybera.ca"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "2605:fd00::/32"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "::/0"
  }
}

resource "openstack_compute_instance_v2" "packer_node" {
  name = "packer.cybera.ca"
  image_name = "Ubuntu 18.04"
  flavor_name = "m1.small"
  key_pair = "packer"
  security_groups = ["${openstack_compute_secgroup_v2.packer.name}"]
  lifecycle {
    ignore_changes = ["image_name", "image_id"]
  }
}

resource "null_resource" "install" {
  connection {
    user = "ubuntu"
    private_key = "${file("./key/packer")}"
    host = "${openstack_compute_instance_v2.packer_node.access_ip_v6}"
    agent = false
  }

  provisioner "file" {
    source = "./files"
    destination = "files"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/ubuntu/files/bootstrap.sh",
    ]
  }
}

