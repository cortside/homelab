# Multiple VMs Configuration
variable "vms" {
  description = "Map of VMs to create with their configurations"
  type = map(object({
    cores  = number
    memory = number
    #    ip     = string
  }))
  default = {
    "vm01" = {
      cores  = 2
      memory = 4096
      #      ip     = "192.168.1.101/24"
    },
    # "db" = {
    #   cores  = 4
    #   memory = 8192
    #   ip     = "192.168.1.102/24"
    # }
  }
}

# Proxmox Provider Configuration
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.0.20:8006/api2/json"
}

variable "proxmox_user" {
  description = "Proxmox user for API access"
  type        = string
  default     = "terraform@pam"
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
  default     = "pve"
}

# VM Template Configuration
variable "vm_template" {
  description = "Name of the Proxmox template to clone"
  type        = string
  default     = "ubuntu-24.04-cloud-init-template"
}

# VM Basic Configuration
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
  default     = "ubuntu-cloudinit"

  validation {
    condition     = length(var.vm_name) > 0
    error_message = "VM name cannot be empty."
  }
}

variable "vm_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_cores > 0 && var.vm_cores <= 32
    error_message = "VM cores must be between 1 and 32."
  }
}

variable "vm_memory" {
  description = "Amount of memory in MB for the VM"
  type        = number
  default     = 2048

  validation {
    condition     = var.vm_memory >= 512
    error_message = "VM memory must be at least 512 MB."
  }
}

variable "vm_sockets" {
  description = "Number of CPU sockets for the VM"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_sockets > 0 && var.vm_sockets <= 4
    error_message = "VM sockets must be between 1 and 4."
  }
}

# VM Hardware Configuration
variable "vm_boot_order" {
  description = "Boot order for the VM"
  type        = string
  default     = "order=ide0;net0"
}

variable "vm_scsihw" {
  description = "SCSI hardware type"
  type        = string
  default     = "virtio-scsi-pci"
}

variable "vm_qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = number
  default     = 1

  validation {
    condition     = contains([0, 1], var.vm_qemu_agent)
    error_message = "QEMU agent must be 0 (disabled) or 1 (enabled)."
  }
}

# Network Configuration
variable "vm_network_model" {
  description = "Network model for the VM"
  type        = string
  default     = "virtio"
}

variable "vm_network_bridge" {
  description = "Network bridge for the VM"
  type        = string
  default     = "vmbr0"
}

# Disk Configuration
variable "vm_disk_type" {
  description = "Disk type for the VM"
  type        = string
  default     = "scsi"
}

variable "vm_disk_storage" {
  description = "Storage location for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "vm_disk_size" {
  description = "Size of the VM disk"
  type        = string
  default     = "10G"
}

# Cloud-Init Configuration
variable "vm_ci_user" {
  description = "Cloud-init username"
  type        = string
  default     = "ubuntu"
}

variable "vm_ci_password" {
  description = "Cloud-init password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vm_ip_config" {
  description = "IP configuration for the VM (e.g., 'ip=192.168.1.110/24,gw=192.168.1.1')"
  type        = string
  default     = ""
}

variable "vm_ssh_keys" {
  description = "Path to SSH public key file"
  type        = string
  default     = ""
}

variable "vm_tags" {
  description = "Tags for the VM"
  type        = string
  default     = "terraform,ubuntu"
}

# Legacy variables (kept for backward compatibility)
variable "ssh_key_path" {
  description = "Path to SSH public key file (deprecated, use vm_ssh_keys)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_ip" {
  description = "VM IP address (deprecated, use vm_ip_config)"
  type        = string
  default     = ""
}

variable "gateway" {
  description = "Gateway IP address (deprecated, use vm_ip_config)"
  type        = string
  default     = ""
}

# LXC variables (if needed for future use)
variable "lxc_name" {
  description = "Name of the LXC container"
  type        = string
  default     = "alpine-lxc"
}

variable "lxc_template" {
  description = "LXC template path"
  type        = string
  default     = "local:vztmpl/alpine-3.19-default_20240110_amd64.tar.xz"
}

variable "lxc_ip" {
  description = "LXC container IP address"
  type        = string
  default     = ""
}