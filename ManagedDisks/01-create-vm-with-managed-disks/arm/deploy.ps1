$ResourceGroupName = "demo-md-1"
$Location = "canadacentral"

# Select Subscription
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Internal Consumption"

# Create new resource group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose

# Deploy ARM Template
New-AzureRmResourceGroupDeployment `
    -Name "deploy" `
    -ResourceGroupName $ResourceGroupName `
    -Mode Incremental `
    -TemplateFile "deploy.json" `
    -Verbose