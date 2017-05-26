$Location = "canadacentral"
$ResourceGroupName = "demo-md-2"
$VMName = "vm3"

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Deallocate VM + set the state to generalized
Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force
Set-AzureRmVm -ResourceGroupName $ResourceGroupName -Name $VMName -Generalized
