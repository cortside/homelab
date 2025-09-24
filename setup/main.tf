resource "proxmox_vm_qemu" "cloudinit-test" {
  #count       = var.num_docker_nodes
  count = 2
  name        = "dh0${count.index}"
  #name        = var.vm_name


  description = "Docker Node ${count.index}"
  depends_on  = [null_resource.cloud_init_test1]
  # Node name has to be the same name as within the cluster
  # this might not include the FQDN
  target_node = var.proxmox_node

  # The template name to clone this vm from
  clone = var.template_name
  # Activate QEMU agent for this VM
  agent = 1

  os_type = "cloud-init"
  cpu {
    cores   = 6
    sockets = 1
  }
  memory = 8192
  scsihw = "virtio-scsi-single"

  # Setup the disk
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "warren"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size     = "32G"
          storage  = "warren"
          discard  = true
          iothread = true
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.nic_name
    #tag    = -1
  }

  # Setup the ip address using cloud-init.
  boot = "order=scsi0"
  # Keep in mind to use the CIDR notation for the ip.
  ipconfig0 = "ip=dhcp,ip6=dhcp"
  skip_ipv6 = true

  lifecycle {
    ignore_changes = [
      ciuser,
      sshkeys,
      network
    ]
  }
  #cicustom = "user=local:snippets/cloud_init_test1.yml"

  cloud_init {
    user_data = templatefile("${path.module}/user_data_cloud_init_test1.cfg", {
      ssh_key  = var.ssh_key
      hostname = "dh0${count.index}"
      domain   = "local"
    })
  }

#   cloud_init {
#     cicustom = "user=${proxmox_virtual_environment_file.cloud_init_user_data.id}"
#     user_data = templatefile("${path.module}/cloud-init-user-data.yaml", {
#       hostname = "my-ubuntu-vm" # Dynamic hostname
#     })
#   }
}

# resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
#   content_type = "snippets"
#   datastore_id = "local" # Or your desired datastore ID
#   node_name    = "pve"   # Or your desired node name
#   source_file {
#     path = "${path.module}/cloud-init-user-data.yaml"
#   }
# }