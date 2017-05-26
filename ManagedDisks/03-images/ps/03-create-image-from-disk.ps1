$Location = "canadacentral"
$ResourceGroupName = "demo-md-2"
$DiskName = "vm3-osdisk"

$ImageName = $DiskName + "-image"
$ImageResourceGroup = $ResourceGroupName

# Select Subscription
Select-AzureRMSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Retrieve Disk
$Disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Verbose

# Create Image configuration
$ImageConfig = New-AzureRmImageConfig -Location $Location -Verbose
$ImageConfig = Set-AzureRmImageOsDisk -Image $ImageConfig -OsState Generalized -OsType Windows -ManagedDiskId $Disk.Id -Verbose

# Create Resource Group, if it doesn't exist
New-AzureRmResourceGroup -Name $ImageResourceGroup -Location $Location -Verbose

# Create Image
New-AzureRmImage -ImageName $ImageName -ResourceGroupName $ImageResourceGroup -Image $imageConfig -Verbose