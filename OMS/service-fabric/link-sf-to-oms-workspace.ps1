$OMSWorkspaceSubscriptionID = "OMS_SUBSCRIPTION_ID"
$OMSWorkspaceResourceGroup = "OMS_RESOURCE_GROUP"
$OMSWorkspaceName = "OMS_WORKSPACE_NAME"
$OMSWorkspaceServiceFabricInsightName = "UNIQUE_NAME" #this must be unique per service fabric cluster you want to monitor

$ServiceFabricSubscriptionID = "SERVICE_FABRIC_SUBSCRIPTOIN_ID"
$ServiceFabricDiagnosticsStorageAccountName = "SERVICE_FABRIC_STORAGE_ACCOUNT"
$ServiceFabricDiagnosticsStorageAccountResourceGroup = "SERVICE_FABRIC_STORAGE_ACCOUNT_RG"

# Do not change anything below ----
$ServiceFabricValidOMSTables = "WADServiceFabric*EventTable", "WADETWEventTable"


# Select the subscription where Service Fabric is deployed
Select-AzureRmSubscription -SubscriptionId $ServiceFabricSubscriptionID -Verbose

$StorageAccount = Get-AzureRmStorageAccount `
                        -ResourceGroupName $ServiceFabricDiagnosticsStorageAccountResourceGroup `
                        -Name $ServiceFabricDiagnosticsStorageAccountName `
                        -Verbose

$StorageAccountKey = (Get-AzureRmStorageAccountKey `
                        -ResourceGroupName $ServiceFabricDiagnosticsStorageAccountResourceGroup `
                        -Name $ServiceFabricDiagnosticsStorageAccountName `
                        -Verbose)[0].Value `

# Select the subscription where OMS Workspace is deployed
Select-AzureRmSubscription -SubscriptionId $OMSWorkspaceSubscriptionID -Verbose

$Workspace = Get-AzureRmOperationalInsightsWorkspace `
                    -ResourceGroupName $OMSWorkspaceResourceGroup `
                    -Name $OMSWorkspaceName `
                    -Verbose

$ExistingConfig = ""

try
{
    $ExistingConfig = Get-AzureRmOperationalInsightsStorageInsight `
                            -Workspace $Workspace `
                            -Name $OMSWorkspaceServiceFabricInsightName `
                            -ErrorAction Stop `
                            -Verbose
}
catch [Hyak.Common.CloudException]
{
    # HTTP Not Found is returned if the storage insight doesn't exist
}

if ($ExistingConfig)
{
    Write-Host("Insight Name is already in use.  Name: " + $OMSWorkspaceServiceFabricInsightName)
    Write-Host("This script is only meant to be used to create new connections.")
}
else
{
    New-AzureRmOperationalInsightsStorageInsight `
        -Workspace $Workspace `
        -Name $OMSWorkspaceServiceFabricInsightName `
        -StorageAccountResourceId $StorageAccount.Id `
        -StorageAccountKey $StorageAccountKey `
        -Tables $ServiceFabricValidOMSTables `
        -Verbose

    Write-Host("Linked Storage account to OMS Workspace.  Insight Name: " + $OMSWorkspaceServiceFabricInsightName)
}