$Location = "canadacentral"
$ResourceGroupName = "demo-md-2"
$VMName = "vm3"

$ImageName = $VMName + "-image"
$ImageResourceGroup = $ResourceGroupName

# Select Subscription
Select-AzureRMSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Retrieve Disk
$VM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Verbose

# Create Image configuration for the full VM
$ImageConfig = New-AzureRmImageConfig -Location $Location -SourceVirtualMachineId $VM.ID -Verbose

# Create Resource Group, if it doesn't exist
New-AzureRmResourceGroup -Name $ImageResourceGroup -Location $Location -Verbose

# Create Image
New-AzureRmImage -ImageName $ImageName -ResourceGroupName $ImageResourceGroup -Image $imageConfig -Verbose