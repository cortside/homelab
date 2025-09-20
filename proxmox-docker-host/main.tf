terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_token_id}=${var.proxmox_token_secret}"
  insecure  = var.proxmox_tls_insecure
}

data "proxmox_virtual_environment_vms" "all_vms" {
  node_name = var.proxmox_node
}

locals {
  template_vms = [
    for vm in data.proxmox_virtual_environment_vms.all_vms.vms : vm
    if vm.name == var.vm_template
  ]
  template_vm_id = length(local.template_vms) > 0 ? local.template_vms[0].vm_id : null
}



resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  for_each  = var.vms
  name      = each.key
  node_name = var.proxmox_node

  # Clone from template
  clone {
    vm_id = 9000
    full  = true
  }

  # CPU Configuration
  cpu {
    cores   = each.value.cores
    sockets = var.vm_sockets
  }

  # Memory Configuration
  memory {
    dedicated = each.value.memory
  }

  # SCSI Hardware
  scsi_hardware = var.vm_scsihw

  # Agent Configuration
  agent {
    enabled = var.vm_qemu_agent == 1 ? true : false
  }

  # Network Configuration
  network_device {
    bridge = var.vm_network_bridge
    model  = var.vm_network_model
  }

  # Cloud-Init Configuration
  initialization {
    user_account {
      username = var.vm_ci_user
      password = var.vm_ci_password
      keys     = var.vm_ssh_keys != "" ? [file(var.vm_ssh_keys)] : []
    }

    ip_config {
      ipv4 {
        address = var.vm_ip_config != "" && var.vm_ip_config != "ip=dhcp" ? split(",", var.vm_ip_config)[0] : "dhcp"
        gateway = var.vm_ip_config != "" && var.vm_ip_config != "ip=dhcp" ? split("=", split(",", var.vm_ip_config)[1])[1] : null
      }
    }
  }

  #   # Wait for cloud-init to complete
  #   provisioner "remote-exec" {
  #     connection {
  #       type     = "ssh"
  #       user     = var.vm_ci_user
  #       password = var.vm_ci_password
  #       host     = split("/", each.value.ip)[0]
  #       timeout  = "5m"
  #     }

  #     inline = [
  #       "cloud-init status --wait"
  #     ]
  #   }

  #   connection {
  #     type        = "ssh"
  #     user        = var.vm_ci_user
  #     password    = var.vm_ci_password
  #     host        = self.ipv4_addresses[0]
  #   }

  #   # Install and configure Docker
  #   provisioner "remote-exec" {
  #     inline = [
  #       "sudo apt update -y",
  #       "sudo apt upgrade -y",
  #       "sudo apt install -y docker.io",
  #       "sudo systemctl start docker",
  #       "sudo systemctl enable docker",
  #       "sudo groupadd docker || true",
  #       "sudo usermod -aG docker ${var.vm_ci_user}",
  #       "sudo chown root:docker /var/run/docker.sock",
  #       "sudo chown -R root:docker /var/run/docker",
  #       "echo 'Docker installation completed successfully'",
  #       "docker --version"
  #     ]
  #   }

  #   # Capture Docker installation status
  #   provisioner "local-exec" {
  #     command = "echo 'VM ${each.key} - Docker installation completed at $(date)' >> docker_install_log.txt"
  #   }  

  # Tags
  tags = split(",", var.vm_tags)
}
