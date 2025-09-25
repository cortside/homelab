# TF vars for spinning up VMs

# Set your public SSH key here
variable "ssh_key" {
  default = "ssh-ed25519 <My SSH Public Key> aurelia@desktop"
}
#Establish which Proxmox host you'd like to spin a VM up on
variable "proxmox_host" {
  default = "192.168.0.20" # IP or FQDN of Proxmox host
}
variable "proxmox_node" {
  default = "pve"
}
# root password for the Proxmox host
# This is only used for the file provisioner to copy the cloud-init file to the host
variable "proxmox_host_password" {
}

#Specify which template name you'd like to use
variable "template_name" {
  default = "ubuntu-24.04-cloud-init-template"
}
#Establish which nic you would like to utilize
variable "nic_name" {
  default = "vmbr0"
}

# I don't have VLANs set up
# #Establish the VLAN you'd like to use 
# variable "vlan_num" {
#     default = "place_vlan_number_here"
# }

#Provide the url of the host you would like the API to communicate on.
#It is safe to default to setting this as the URL for what you used
#as your `proxmox_host`, although they can be different
variable "api_url" {
  default = "https://192.168.0.20:8006/api2/json"
}
#Blank var for use by terraform.tfvars
variable "token_secret" {
}
#Blank var for use by terraform.tfvars
variable "token_id" {
}



# Declare the vm_name variable
variable "vm_name" {
  description = "The hostname for the VM"
  type        = string
}
variable "pm_tls_insecure" {
  description = "Set to true to disable TLS verification"
  type        = bool
  default     = true
}

variable "proxmox_host_password_hash" {
  description = "The hashed password for the Proxmox host"
  type        = string
}

variable "proxmox_host_user" {
  description = "The user for the Proxmox host"
  type        = string
  default     = "ubuntu"
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 3
  validation {
    condition     = var.worker_count > 0
    error_message = "Worker count must be a positive number"
  }
}

variable "cifs_username" {
  description = "The username for the CIFS share"
  type        = string

}

variable "cifs_password" {
  description = "The password for the CIFS share"
  type        = string
}