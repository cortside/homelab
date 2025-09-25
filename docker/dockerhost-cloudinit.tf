# cloud-init.tf - This is where I store cloud-init configuration

# Create a local copy of the file, to transfer to Proxmox.
resource "local_file" "cloud_init_dockerhost_file" {
  count = var.worker_count
  content = templatefile("${path.module}/files/cloudinit-dockerhost.yml", {
    ssh_key       = file("~/.ssh/id_ed25519.pub")
    hostname      = "${var.vm_name}${format("%02d", count.index + 1)}"
    domain        = "local"
    username      = var.proxmox_host_user
    password_hash = var.proxmox_host_password_hash
    cifs_username = var.cifs_username
    cifs_password = var.cifs_password
  })
  filename = "${path.module}/files/cloudinit-${var.vm_name}${format("%02d", count.index + 1)}.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_dockerhost_files" {
  count = var.worker_count
  connection {
    type     = "ssh"
    user     = "root"
    password = var.proxmox_host_password
    host     = var.proxmox_host
  }

  provisioner "file" {
    source      = local_file.cloud_init_dockerhost_file[count.index].filename
    destination = "/var/lib/vz/snippets/cloud_init_${var.vm_name}${format("%02d", count.index + 1)}.yml"
  }
}