$ResourceGroupName = "demo-md-2"
$Location = "canadacentral"
$VNETName = "vnet"
$SubnetName = "default"
$VMName = "vm2"

# VM Username
$VMAdminUsername = "mddemo"
$VMAdminPassword = "Canada1234!!"
$VMAdminPasswordSecure = ConvertTo-SecureString $VMAdminPassword -AsPlainText -Force
$VMCredentials = New-Object System.Management.Automation.PSCredential ($VMAdminUsername, $VMAdminPasswordSecure)

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Create new Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose

# Create new VNET + Subnet
$VNET = New-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix 10.0.0.0/16
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNET -AddressPrefix 10.0.0.0/24 -Verbose
Set-AzureRmVirtualNetwork -VirtualNetwork $VNET -Verbose

# Retrieve VNET
$VNET = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNETName -Verbose

# Create Public IP
$PipName = $VMName + "-pip"
$PublicIP = New-AzureRmPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic -Verbose

# Create NIC
$NicName = $VMName + "-nic"
$Nic = New-AzureRMNetworkInterface -ResourceGroupName $ResourceGroupName  -Location $Location  -Name $NicName -SubnetId $VNET.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -Verbose

# Define VM
$VM = New-AzureRmVMConfig -VMName $VMName -VMSize "Standard_DS2_v2" -Verbose

$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName $VMName -Credential $VMCredentials -ProvisionVMAgent -EnableAutoUpdate -Verbose
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest" -Verbose
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $Nic.Id -Verbose

$OSDiskName = $VMName + "-osdisk"
$VM = Set-AzureRmVMOSDisk -VM $VM  -Name $OSDiskName -DiskSizeInGB 512 -CreateOption FromImage -Caching ReadWrite -Verbose

# Add Disks
Add-AzureRmVMDataDisk -VM $VM -Name ($VMName + "-datadisk-1") -DiskSizeInGB 128 -CreateOption Empty -Caching None -Lun 1 -StorageAccountType PremiumLRS -Verbose
Add-AzureRmVMDataDisk -VM $VM -Name ($VMName + "-datadisk-2") -DiskSizeInGB 128 -CreateOption Empty -Caching None -Lun 2 -StorageAccountType PremiumLRS -Verbose

# Create VM
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VM -Verbose
