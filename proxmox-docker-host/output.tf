# VM Information Outputs
output "vm_ids" {
  description = "The IDs of the created VMs"
  value       = { for k, v in proxmox_virtual_environment_vm.ubuntu_vm : k => v.vm_id }
}

output "vm_names" {
  description = "The names of the created VMs"
  value       = { for k, v in proxmox_virtual_environment_vm.ubuntu_vm : k => v.name }
}

output "vm_nodes" {
  description = "The Proxmox nodes where the VMs are running"
  value       = { for k, v in proxmox_virtual_environment_vm.ubuntu_vm : k => v.node_name }
}

output "vm_template_name" {
  description = "The template name used to create the VM"
  value       = var.vm_template
}

output "vm_template_id" {
  description = "The template ID used to create the VM"
  value       = local.template_vm_id
}

# VM Configuration Outputs
output "vm_cores" {
  description = "Number of CPU cores assigned to each VM"
  value       = { for k, v in var.vms : k => v.cores }
}

output "vm_memory" {
  description = "Amount of memory (MB) assigned to each VM"
  value       = { for k, v in var.vms : k => v.memory }
}

# output "vm_ip_addresses" {
#   description = "IP addresses configured for each VM"
#   value       = { for k, v in var.vms : k => v.ip }
# }

# Network Information
output "vm_ip_config" {
  description = "IP configuration of the VM"
  value       = var.vm_ip_config
  sensitive   = false
}

output "vm_network_bridge" {
  description = "Network bridge used by the VM"
  value       = var.vm_network_bridge
}

# Cloud-Init Information
output "vm_ci_user" {
  description = "Cloud-init username"
  value       = var.vm_ci_user
}

# VM Status and Connection Info
output "vm_tags" {
  description = "Tags assigned to the VM"
  value       = var.vm_tags
}

# SSH Connection Information
output "ssh_connection_info" {
  description = "SSH connection information for each VM"
  value = {
    for k, v in var.vms : k => {
      user    = var.vm_ci_user
      host    = "dhcp"
      command = "ssh ${var.vm_ci_user}@<vm_ip>"
    }
  }
}

# # Docker Installation Status
# output "docker_install_status" {
#   description = "Docker installation status for each VM"
#   value = {
#     for k, v in proxmox_virtual_environment_vm.ubuntu_vm : k => {
#       vm_id = v.vm_id
#       status = "Docker installation completed"
#       log_file = "${var.vm_name}${k}-docker_install_log.txt"
#     }
#   }
#   depends_on = [proxmox_virtual_environment_vm.ubuntu_vm]
# }

# Summary Output
output "vm_summary" {
  description = "Summary of all created VMs"
  value = {
    for k, v in proxmox_virtual_environment_vm.ubuntu_vm : k => {
      id            = v.vm_id
      name          = v.name
      node          = v.node_name
      template_id   = local.template_vm_id
      template_name = var.vm_template
      cores         = var.vms[k].cores
      memory        = var.vms[k].memory
      ip_address    = "dhcp"
      tags          = var.vm_tags
      #      docker_status = "Installed"
    }
  }
}