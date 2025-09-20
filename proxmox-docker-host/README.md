# Docker Host provisioning by Terraform

This Terraform configuration provisions Ubuntu VMs on Proxmox with Docker pre-installed.

## References

- https://www.virtualizationhowto.com/2025/08/instant-vms-and-lxcs-on-proxmox-my-go-to-terraform-templates-for-quick-deployments/
- For multiple VMs: https://tekanaid.com/posts/terraform-proxmox-ubuntu2404/#code

## Variables Reference

### Currently Used Variables

#### Proxmox Provider Configuration
- `proxmox_api_url` - Proxmox API URL (default: "https://192.168.0.20:8006/api2/json")
- `proxmox_user` - Proxmox user for API access (default: "terraform@pam")
- `proxmox_token_id` - Proxmox API token ID (sensitive)
- `proxmox_token_secret` - Proxmox API token secret (sensitive)
- `proxmox_tls_insecure` - Skip TLS verification (default: true)
- `proxmox_node` - Proxmox node name (default: "pve")

#### VM Template Configuration
- `vm_template` - Name of the Proxmox template to clone (default: "ubuntu-24.04-cloud-init-template")

#### VM Configuration (Multiple VMs)
- `vms` - Map of VMs to create with their configurations:
  ```hcl
  vms = {
    "vm01" = {
      cores  = 2
      memory = 4096
    }
  }
  ```

#### Network Configuration
- `vm_network_model` - Network model (default: "virtio")
- `vm_network_bridge` - Network bridge (default: "vmbr0")

#### Cloud-Init Configuration
- `vm_ci_user` - Cloud-init username (default: "ubuntu")
- `vm_ci_password` - Cloud-init password (sensitive)
- `vm_ssh_keys` - Path to SSH public key file
- `vm_ip_config` - IP configuration (e.g., "ip=192.168.1.110/24,gw=192.168.1.1" or "ip=dhcp")

#### VM Tags
- `vm_tags` - Tags for the VM (default: "terraform,ubuntu")

### Unused Variables (Available for Cleanup)

#### Legacy Single VM Variables (Not Used)
- `vm_name` - VM name (replaced by VM keys in `vms` map)
- `vm_cores` - CPU cores (replaced by `vms[].cores`)
- `vm_memory` - Memory in MB (replaced by `vms[].memory`)
- `vm_sockets` - CPU sockets (not implemented)

#### Hardware Configuration (Not Implemented)
- `vm_boot_order` - Boot order configuration
- `vm_scsihw` - SCSI hardware type
- `vm_qemu_agent` - QEMU guest agent setting

#### Disk Configuration (Not Implemented)
- `vm_disk_type` - Disk type
- `vm_disk_storage` - Storage location
- `vm_disk_size` - Disk size

#### Legacy Variables (Deprecated)
- `ssh_key_path` - SSH key path (use `vm_ssh_keys` instead)
- `vm_ip` - VM IP address (use `vm_ip_config` instead)
- `gateway` - Gateway IP (use `vm_ip_config` instead)

#### LXC Variables (Not Used in VM Setup)
- `lxc_name` - LXC container name
- `lxc_template` - LXC template path
- `lxc_ip` - LXC container IP

## Usage

1. Copy `main.tf.example` to `main.tf` and configure as needed
2. Set your variables in `terraform.tfvars`
3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Example Configuration

See `terraform.tfvars` for a complete example configuration.
