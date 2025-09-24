# cloud-init.tf - This is where I store cloud-init configuration

# Source the Cloud Init Config file. NB: This file should be located 
# in the "files" directory under the directory you have your Terraform
# files in.
data "template_file" "cloud_init_dh02" {
  template = file("${path.module}/files/cloudinit-dockerhost.yml")

  vars = {
    ssh_key  = file("~/.ssh/id_ed25519.pub")
    hostname = "dh02"
    domain   = "local"
  }
}

# Create a local copy of the file, to transfer to Proxmox.
resource "local_file" "cloud_init_dh02" {
  content  = data.template_file.cloud_init_dh02.rendered
  filename = "${path.module}/files/cloudinit-dockerhost.yml"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_dh02" {
  connection {
    type     = "ssh"
    user     = "root"
    password = var.proxmox_host_password
    #private_key = file("~/.ssh/id_ed25519")
    host = var.proxmox_host
  }

  provisioner "file" {
    source      = local_file.cloud_init_dh02.filename
    destination = "/var/lib/vz/snippets/cloud_init_dh02.yml"
  }
}