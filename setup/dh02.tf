resource "proxmox_vm_qemu" "dh02" {
  name        = "dh02" // var.vm_name
  description = "Docker Host 02"
  depends_on  = [null_resource.cloud_init_dh02]
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
  #cpu = "host"
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
          size     = "250G"
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
  cicustom = "user=local:snippets/cloud_init_dh02.yml"
}