$ResourceGroupName = 'demo-md-a'
$AvailabilitySetName = 'demoSet'

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Retrieve Availability Set
$AvSet = Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailabilitySetName -Verbose

# Convert Availability Set to **Managed**
Update-AzureRmAvailabilitySet -AvailabilitySet $AvSet -Managed -Verbose

# Convert all of the VMs
foreach($VMInfo in $AvSet.VirtualMachinesReferences)
{
    # Retrieve VM
    $VM =  Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Where-Object {$_.Id -eq $VMInfo.id}

    # Stop VM
    Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VM.Name -Force -Verbose

    # Convert
    ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $ResourceGroupName -VMName $VM.Name -Verbose

    # Start VM
    Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VM.Name
}