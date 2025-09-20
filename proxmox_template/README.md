# Proxmox Ubuntu 24.04 Cloud-Init Template Creator

This directory contains scripts and configuration files to create an Ubuntu 24.04 LTS cloud-init template in Proxmox VE with the QEMU guest agent pre-installed.

## Overview

The template created by this script includes:
- Ubuntu 24.04 LTS (Noble Numbat) base image
- QEMU guest agent for better VM management
- Cloud-init support for automated VM provisioning
- Default user: `ubuntu` with configurable password

## Prerequisites

Before running this script, ensure you have:

1. **Proxmox VE host** with root or sufficient privileges
2. **Ubuntu 24.04 cloud image** downloaded to `/var/lib/vz/template/iso/`
3. **Storage configured** (script assumes `local-lvm` storage)
4. **Available VM ID 9000** (or modify the script to use a different ID)

### Download Ubuntu Cloud Image

If you haven't already downloaded the Ubuntu 24.04 cloud image, run this on your Proxmox host:

```bash
cd /var/lib/vz/template/iso/
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

## Files Description

- `create-template.sh` - Main script that creates the VM template
- `user-data.yml` - Cloud-init configuration that installs and enables QEMU guest agent
- `README.md` - This documentation

## Installation Steps

### 1. Copy Files to Proxmox Host

Copy the required files to your Proxmox VE host:

```bash
# Copy the creation script
scp create-template.sh root@your-proxmox-host:/root/

# Copy the cloud-init configuration
scp user-data.yml root@your-proxmox-host:/var/lib/vz/snippets/
```

### 2. Set Execute Permissions

On the Proxmox host, make the script executable:

```bash
chmod +x /root/create-template.sh
```

### 3. Run the Template Creation Script

Execute the script to create the template:

```bash
cd /root
./create-template.sh
```

The script will:
1. Create a new VM with ID 9000
2. Import the Ubuntu 24.04 cloud disk image
3. Configure storage and boot settings
4. Set up cloud-init with QEMU guest agent
5. Configure default networking (DHCP)

### 4. Convert VM to Template

After the script completes successfully, convert the VM to a template:

```bash
qm template 9000
```

## Usage

Once the template is created, you can clone it to create new VMs:

```bash
# Clone the template to create a new VM
qm clone 9000 101 --name my-new-vm

# Start the new VM
qm start 101
```

## Customization

### Modify VM Specifications

Edit `create-template.sh` to change:
- **Memory**: Change `--memory 2048` (default: 2GB)
- **CPU cores**: Change `--cores 2` (default: 2 cores)
- **Network bridge**: Change `bridge=vmbr1` to your desired bridge
- **VM ID**: Change `9000` to an available ID

### Modify Default Credentials

In `create-template.sh`, update the line:
```bash
qm set 9000 --ciuser ubuntu --cipassword 'your-favorite_password'
```

**⚠️ Security Note**: Consider using SSH keys instead of passwords for production environments.

### Add More Cloud-Init Packages

Edit `user-data.yml` to install additional packages:
```yaml
packages:
  - qemu-guest-agent
  - htop
  - curl
  - vim
```

## Troubleshooting

### Common Issues

1. **VM ID already exists**: Change the VM ID in the script or remove the existing VM
2. **Storage not found**: Verify `local-lvm` storage exists or change to your storage name
3. **Image not found**: Ensure the Ubuntu cloud image is downloaded to the correct path
4. **Permissions error**: Run the script as root or with sufficient privileges

### Verification

After creating the template, verify it was created successfully:

```bash
# List all VMs and templates
qm list

# Check template configuration
qm config 9000
```

## Network Configuration

The template uses DHCP by default. To use static IP addressing, modify the cloud-init configuration when cloning:

```bash
# Clone with static IP
qm clone 9000 101 --name my-vm
qm set 101 --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1
```

## Next Steps

After creating VMs from this template:
1. The QEMU guest agent will be automatically installed and running
2. You can use Proxmox's guest agent features (shutdown, restart, etc.)
3. Cloud-init will handle initial VM configuration
4. SSH into the VM using the configured credentials

For more advanced cloud-init configurations, refer to the [cloud-init documentation](https://cloudinit.readthedocs.io/).

