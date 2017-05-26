# DISCLIAMER
# This script is provided as a reference.  Please thoroughly test and
# verify functionality in a non-production environment where dataloss is
# allowed.

# Assumptions:
# - Operating on Managed Disks
# - Extensions are not installed through this script
# - VM Diagnostics needs to be turn on manually
# - 3 Fault Domains & 3 Update Domains - assuming that the region you've selected has 3 fault domains.  See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability for number of fault domains in each region.

# At the end of execution, the VM will be recreated and added to the availability set.

# NOTE:  NOTHING WILL BE DELETED WITHOUT USER APPROVAL THROUGH PROMPTS

$ResourceGroupName = "test-avset"
$VMName = "vm3"
$AvailabilitySetName = "test-vm-set"
$AvailabilitySetFaultDomain = 3
$AvailabilitySetUpdateDomain = 3

# Retrieve the existing VM
$VM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

# Retrieve the VM location
$Location = $VM.Location

# Retrieve the OS Disk
$OSManagedDiskID = $VM.StorageProfile.OsDisk.ManagedDisk.Id
$OSDiskName = $OSManagedDiskID.Substring($OSManagedDiskID.LastIndexOf("/") + 1)
$OSDisk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $OSDiskName
$OSDiskStorageAccountType = $OSDisk.AccountType

# Create Snapshot of the OS Disk
$Snapshot = New-AzureRmSnapshotConfig -SourceUri $OSDisk.Id -CreateOption Copy -AccountType $OSDiskStorageAccountType -Location $Location -Verbose
$SnapshotName = $OSDiskName + "-snapshot"
New-AzureRmSnapshot -Snapshot $Snapshot -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroupName -Verbose

# Retrieve Snapshot of the OS Disk
$SnapshotDisk = Get-AzureRmSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $SnapshotName -Verbose

# Create a new OS Disk from Snapshot
$OSDiskConfig = New-AzureRmDiskConfig -AccountType $OSDiskStorageAccountType -DiskSizeGB $OSDisk.DiskSizeGB -SourceResourceId $SnapshotDisk.Id -Location $Location -CreateOption Copy -Verbose
$NewOSDiskName = $OSDiskName + "_2"
New-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $NewOSDiskName -Disk $OSDiskConfig -Verbose
$NewOSDisk = Get-AzureRMDisk -ResourceGroupName $ResourceGroupName -DiskName $NewOSDiskName -Verbose

# Create new availability set
New-AzureRmAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $ResourceGroupName  -Location $VM.Location -Managed -PlatformFaultDomainCount $AvailabilitySetFaultDomain -PlatformUpdateDomainCount $AvailabilitySetUpdateDomain -Verbose
$AvailabilitySet = Get-AzureRmAvailabilitySet -Name $AvailabilitySetName -ResourceGroupName $ResourceGroupName -Verbose

# Create new VM
$NewVM = New-AzureRMVMConfig -VMName $VMName -VMSize $VM.HardwareProfile.VmSize -AvailabilitySetId $AvailabilitySet.Id

## Add the Nics
ForEach ($NIC in $VM.NetworkProfile.NetworkInterfaces)
{
    if ($NIC.Primary)
    {
        $NewVM = Add-AzureRMVMNetworkInterface -VM $NewVM -Id $NIC.Id -Primary -Verbose
    }
    else
    {
        $NewVM = Add-AzureRMVMNetworkInterface -VM $NewVM -Id $NIC.Id -Verbose
    }
}

## Add the Disks
if ($OSDisk.OsType -eq "Linux")
{
    Set-AzureRmVMOSDisk -VM $NewVM -Linux -CreateOption Attach -ManagedDiskId $NewOSDisk.Id -StorageAccountType $OSDiskStorageAccountType -Verbose
}
else
{
    Set-AzureRmVMOSDisk -VM $NewVM -Windows -CreateOption Attach -ManagedDiskId $NewOSDisk.Id -StorageAccountType $OSDiskStorageAccountType -Verbose
}

ForEach ($DataDisk in $VM.StorageProfile.DataDisks)
{
    Add-AzureRmVMDataDisk -VM $NewVM -CreateOption Attach -Caching $DataDisk.Caching -ManagedDiskId $DataDisk.ManagedDisk.Id -StorageAccountType $DataDisk.ManagedDisk.StorageAccountType -Lun $DataDisk.Lun -Verbose
}

## Set Boot Diagnostics
if ($VM.DiagnosticsProfile.BootDiagnostics.Enabled -eq $true)
{
    $BootDiagUri = $VM.DiagnosticsProfile.BootDiagnostics.StorageUri
    $BootDiagUri -match '^https://([a-z0-9]+).blob.core.windows.net.*$'
    $BootDiagStorageAccountName = $Matches[1]
    Set-AzureRmVMBootDiagnostics -VM $NewVM -Enable -ResourceGroupName $ResourceGroupName -StorageAccountName $BootDiagStorageAccountName
}

## Get the Tags
$Tags = $VM.Tags

# Delete the existing VM
Remove-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Verbose

# Create the VM
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Tags $Tags -Location $Location -VM $NewVM -Verbose

# Delete the Snapshot
Remove-AzureRmSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $SnapshotName -Verbose