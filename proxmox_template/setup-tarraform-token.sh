pveum role add terraform-role --privs "Datastore.AllocateSpace,Datastore.Audit,Pool.Allocate,Sys.Audit,Sys.Console,Sys.Modify,VM.Allocate,VM.Audit,VM.Clone,VM.Config.CDROM,VM.Config.Cloudinit,VM.Config.CPU,VM.Config.Disk,VM.Config.HWType,VM.Config.Memory,VM.Config.Network,VM.Config.Options,VM.Migrate,VM.PowerMgmt,SDN.Use,VM.GuestAgent.Unrestricted,VM.GuestAgent.Audit"

pveum user add terraform@pve 
pveum aclmod / -user terraform@pve -role terraform-role
pveum user token add terraform@pve terraform-token --privsep=0

echo "Terraform user and token created. Please store the token securely."
echo "To view the token, use the command: pveum user token list terraform@pve"

