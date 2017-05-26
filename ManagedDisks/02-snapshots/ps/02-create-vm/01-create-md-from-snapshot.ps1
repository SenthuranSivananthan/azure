$Location = "canadacentral"
$ResourceGroupName = "demo-md-2"
$SnapshotName = "vm2-osdisk-snapshot"
$DiskName = "vm3-osdisk"

# Select Subscription
Select-AzureRMSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Retrieve Snapshot
$Snapshot = Get-AzureRmSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $SnapshotName -Verbose

# Define Disk Configuration
$DiskConfig = New-AzureRmDiskConfig -AccountType PremiumLRS -DiskSizeGB 1023 -SourceResourceId $Snapshot.Id -Location $Location -CreateOption Copy -Verbose

# Create Disk
New-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Disk $DiskConfig -Verbose