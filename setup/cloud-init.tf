# cloud-init.tf - This is where I store cloud-init configuration

# Source the Cloud Init Config file. NB: This file should be located 
# in the "files" directory under the directory you have your Terraform
# files in.
data "template_file" "cloud_init_test1" {
  count = 2
  template = file("${path.module}/user_data_cloud_init_test1.cfg")

  vars = {
    ssh_key  = file("~/.ssh/id_ed25519.pub")
    hostname = "${var.vm_name}${count.index}"
    domain   = "local"
  }
}

# Create a local copy of the file, to transfer to Proxmox.
resource "local_file" "cloud_init_test1" {
    count    = 2
  content  = data.template_file.cloud_init_test1[count.index].rendered
  filename = "${path.module}/files/user_data_cloud_init_test1.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_test1" {
  connection {
    type     = "ssh"
    user     = "root"
    password = var.proxmox_host_password
    #private_key = file("~/.ssh/id_ed25519")
    host = var.proxmox_host
  }

  provisioner "file" {
    source      = local_file.cloud_init_test1[count.index].filename
    destination = "/var/lib/vz/snippets/cloud_init_test1.yml"
  }
}