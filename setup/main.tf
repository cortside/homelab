resource "proxmox_vm_qemu" "cloudinit-test" {
  name       = var.vm_name
  description       = "Testing Terraform and cloud-init"
  depends_on = [null_resource.cloud_init_test1]
  # Node name has to be the same name as within the cluster
  # this might not include the FQDN
  target_node = var.proxmox_node

  # The template name to clone this vm from
  clone = var.template_name
  # Activate QEMU agent for this VM
  agent = 1

  os_type = "cloud-init"
  cpu {
    cores   = 2
    sockets = 1
  }
  #cpu = "host"
  memory = 2048
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
  cicustom = "user=local:snippets/cloud_init_test1.yml"
}