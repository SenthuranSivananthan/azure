$Location = "canadacentral"
$ResourceGroupName = "demo-md-1"
$VMName = "vm1"

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Internal Consumption" -Verbose

# Deallocate VM + set the state to generalized
Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force -Verbose
Set-AzureRmVm -ResourceGroupName $ResourceGroupName -Name $VMName -Generalized -Verbose
