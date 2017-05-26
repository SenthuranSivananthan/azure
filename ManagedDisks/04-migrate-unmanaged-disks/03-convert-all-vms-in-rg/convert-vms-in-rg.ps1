$ResourceGroupName = 'test-2'

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Lab" -Verbose

$VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName

# Convert all of the VMs
foreach($VM in $VMs)
{
    # Stop VM
    Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VM.Name -Force -Verbose

    # Convert
    ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $ResourceGroupName -VMName $VM.Name -Verbose

    # Start VM
    Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VM.Name
}