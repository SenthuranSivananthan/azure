Add-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName Lab

$ResourceGroupName = "test-vm"
$VMName = "vm1"

$VM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

ForEach ($NetworkInterface in $VM.NetworkProfile.NetworkInterfaces)
{
    $NICName = (Get-AzureRmResource -ResourceId $NetworkInterface.Id).Name

    $NIC = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICName
    $NIC.DnsSettings.DnsServers.Add("8.8.4.4")
    $NIC.DnsSettings.DnsServers.Add("8.8.8.8")

    $NIC | Set-AzureRmNetworkInterface
}

Restart-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName