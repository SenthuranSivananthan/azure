$ResourceGroupName = "demo-md-2"
$Location = "canadacentral"
$VNETName = "vnet"
$SubnetName = "default"
$VMName = "vm3"
$ExistingManagedDisk = "vm3-osdisk"

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Create new Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose

# Create new VNET + Subnet
$VNET = New-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix 10.0.0.0/16 -Verbose
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNET -AddressPrefix 10.0.0.0/24 -Verbose
Set-AzureRmVirtualNetwork -VirtualNetwork $VNET -Verbose

# Retrieve VNET
$VNET = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNETName -Verbose

# Create Public IP
$PipName = $VMName + "-pip"
$PublicIP = New-AzureRmPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic -Verbose

# Create NIC
$NicName = $VMName + "-nic"
$Nic = New-AzureRMNetworkInterface -ResourceGroupName $ResourceGroupName  -Location $Location -Name $NicName -SubnetId $VNET.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -Verbose

# Retrieve Disk
$Disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $ExistingManagedDisk -Verbose

# Define VM
$VM = New-AzureRmVMConfig -VMName $VMName -VMSize "Standard_DS2_v2" -Verbose
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $Nic.Id -Verbose

$OSDiskName = $VMName + "-osdisk"
$VM = Set-AzureRmVMOSDisk -VM $VM -CreateOption Attach -ManagedDiskId $Disk.Id -Windows -Caching ReadWrite -Verbose

# Add Disks
Add-AzureRmVMDataDisk -VM $VM -Name ($VMName + "-datadisk-1") -DiskSizeInGB 128 -CreateOption Empty -Caching None -Lun 1 -StorageAccountType PremiumLRS -Verbose
Add-AzureRmVMDataDisk -VM $VM -Name ($VMName + "-datadisk-2") -DiskSizeInGB 128 -CreateOption Empty -Caching None -Lun 2 -StorageAccountType PremiumLRS -Verbose

# Create VM
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VM -Verbose
