Login-AzureRmAccount

$LocationToSave = "c:\temp\"
$DateFormat = Get-Date -Format o | foreach {$_ -replace ":", "."}
$Subscriptions = Get-AzureRmSubscription

Foreach ($Subscription in $Subscriptions)
{
    $SubscriptionId = $Subscription.SubscriptionId
    $SubscriptionName = $Subscription.Name

    Select-AzureRmSubscription -SubscriptionId $SubscriptionId
    Get-AzureRmRoleAssignment | Export-Csv "$LocationToSave\AzureRBACExtract-$SubscriptionId-$SubscriptionName-$DateFormat.csv"
}