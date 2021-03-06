## Policies to audit Virtual Machines & Virtual Machine Scale Sets

**These policies are provided under MIT license.  Please test them in your environment and customize as needed**

| Policy        | Description           | Status  |
| ------------- |-------------| -----  |
| audit-vm-unmanaged-disks.json | Monitor for VMs that are not using managed disks. | Done |
| audit-vm-windows-ahub.json | Monitor for Windows VMs that are using Azure Hybrid Use Benefits. | Done |
| audit-vm-without-availability-sets.json | Monitor for VMs that are not in an availability set.  Adding the VM to an availability set will require the Compute to be recreated. | Done |
| audit-vm-linux-without-ssh-keys.json | Monitor for VMs that are not using SSH Keys for login. | Backlog |
| audit-vm-without-ssd.json | Monitor for VMs that are not using SSDs.  Using SSDs will provide an SLA of 99.9%. | Backlog |
