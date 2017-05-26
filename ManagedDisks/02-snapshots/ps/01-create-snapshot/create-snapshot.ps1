$Location = "canadacentral"
$ResourceGroupName = "demo-md-2"
$Diskname = "vm2-osdisk"

$SnapshotResourceGroup = $ResourceGroupName
$SnapshotName = $Diskname + "-snapshot"

# Select Subscription
Select-AzureRMSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Retrieve Disk
$Disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $Diskname -Verbose

# Create Snapshot configuration
$Snapshot = New-AzureRmSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location -Verbose

# Create Resource Group, if it doesn't exist
New-AzureRmResourceGroup -Name $SnapshotResourceGroup -Location $Location -Verbose

# Create a Snapshot and save to resource group
New-AzureRmSnapshot -Snapshot $Snapshot -SnapshotName $SnapshotName -ResourceGroupName $SnapshotResourceGroup -Verbose
