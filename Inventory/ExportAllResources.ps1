Login-AzureRmAccount

$LocationToSave = "c:\temp\"
$DateFormat = Get-Date -Format o | foreach {$_ -replace ":", "."}
$Subscriptions = Get-AzureRmSubscription

ForEach ($Subscription in $Subscriptions)
{
    $SubscriptionId = $Subscription.SubscriptionId
    $SubscriptionName = $Subscription.Name

    "Generating export for $SubscriptionName ($SubscriptionId)"

    Select-AzureRmSubscription -SubscriptionId $SubscriptionId
    Get-AzureRmResource | Export-Csv "$LocationToSave\AzureResourceExtract-$SubscriptionId-$SubscriptionName-$DateFormat.csv"
}

