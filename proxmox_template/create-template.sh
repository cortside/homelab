#!/bin/bash

# Proxmox VM Template Creation Script
# Creates an Ubuntu 24.04 cloud-init template

set -e  # Exit on any error
set -u  # Exit on undefined variables

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -u, --user USERNAME     Set the cloud-init user (default: ubuntu)"
    echo "  -p, --password PASSWORD Set the cloud-init password (default: password)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Example: $0 --user admin --password mypassword"
}

# Default values
CI_USER="ubuntu"
CI_PASSWORD="password"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user)
            CI_USER="$2"
            shift 2
            ;;
        -p|--password)
            CI_PASSWORD="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

echo "Creating Ubuntu 24.04 cloud-init template..."
echo "Using cloud-init user: $CI_USER"

# Check if VM 9000 already exists and handle it
if qm status 9000 >/dev/null 2>&1; then
    echo "VM 9000 already exists. Removing it..."
    # Stop the VM if it's running
    if qm status 9000 | grep -q "running"; then
        echo "Stopping VM 9000..."
        qm stop 9000
        sleep 5
    fi
    # Destroy the existing VM
    qm destroy 9000
    echo "VM 9000 removed successfully."
fi

echo "Step 1: Creating VM with ID 9000..."
qm create 9000 --name "ubuntu-24.04-cloud-init-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0


echo "Step 2: Importing disk image..."
qm importdisk 9000 /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img local-lvm

echo "Step 3: Setting up SCSI controller and disk..."
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0

echo "Step 4: Configuring boot settings..."
qm set 9000 --boot c --bootdisk scsi0

echo "Step 5: Adding cloud-init drive..."
qm set 9000 --ide2 local-lvm:cloudinit

echo "Step 6: Setting network configuration..."
qm set 9000 --ipconfig0 ip=dhcp

#echo "Step 7: Setting default user credentials..."
#qm set 9000 --ciuser "$CI_USER" --cipassword "$CI_PASSWORD"

echo "Step 8: Adding cloud-init configuration with user settings..."
qm set 9000 --cicustom "user=local:snippets/user-data.yml"

echo "Step 9: Converting VM to template..."
qm template 9000

echo "Template creation completed successfully!"
echo "Template 'ubuntu-24.04-cloud-init-template' is now ready for use with VM ID 9000"