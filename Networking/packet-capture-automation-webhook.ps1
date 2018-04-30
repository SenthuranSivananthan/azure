### This script is used with Log Analytics Alerts as a WebHook

workflow PacketCapture
{
    param  
    (  
        [Parameter(Mandatory=$true)]  
        [string] $ResourceGroup,

        [Parameter(Mandatory=$true)]  
        [string] $Location,

        [Parameter(Mandatory=$true)]  
        [string] $PacketCaptureNamePrefix,        

        [Parameter(Mandatory=$true)]  
        [object] $WebhookData  
    )

    inlinescript
    {
        $ResourceGroup = $Using:ResourceGroup
        $Location = $Using:Location
        $PacketCaptureNamePrefix = $Using:PacketCaptureNamePrefix
        $WebhookData = $Using:WebhookData

        $connectionName = "AzureRunAsConnection"
        try
        {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

            "Logging in to Azure..."
            Add-AzureRmAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        }
        catch {
            if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } else{
                Write-Error -Message $_.Exception
                throw $_.Exception
            }
        }

        $RequestBody = ConvertFrom-Json $WebhookData.RequestBody

        # Storage account to save the packet captures
        $StorageAccountId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/demo-packet-capture/providers/Microsoft.Storage/storageAccounts/sspacketcapturelogs"

        # Network Watcher
        $NWResourceGroup = "NetworkWatcherRG"
        $NWNamePrefix = "NetworkWatcher_"

        $PacketCaptureDurationInSeconds = 60
        $PacketCaptureNameSuffix = $(get-date -f yyyy-MM-dd-HHmmss)

        $ComputerFieldIdx = 0

        For ($i = 0; $i -lt $RequestBody.SearchResult.tables.columns.Count; $i++)
        {
            if ($RequestBody.SearchResult.tables.columns[$i] -eq "Computer")
            {
                $ComputerFieldIdx = $i
            }
        }
        
        $NWName = $NWNamePrefix + $Location
        $NetworkWatcher = Get-AzureRmNetworkWatcher -Name $NWName -ResourceGroupName $NWResourceGroup

        For ($i = 0; $i -lt $RequestBody.SearchResult.tables.rows.Count; $i++)
        {
            $VMName = $RequestBody.SearchResult.tables.rows[$i][$ComputerFieldIdx]
            $VM = Get-AzureRMVM -ResourceGroupName $ResourceGroup -Name $VMName

            if ($VM -ne $null)
            {
                $PacketCaptureName = $PacketCaptureNamePrefix + "-" + $VM.Name + "-" + $PacketCaptureNameSuffix

                #Initiate packet capture on the VM that fired the alert
                Write-Output "Initiating Packet Capture on $($VM.Name)"
                
                New-AzureRmNetworkWatcherPacketCapture -NetworkWatcher $NetworkWatcher -TargetVirtualMachineId $VM.Id -PacketCaptureName $PacketCaptureName -StorageAccountId $StorageAccountId -TimeLimitInSeconds $PacketCaptureDurationInSeconds
            }
            else
            {
                Write-Output "Unable to find $($VMName) in $($ResourceGroup)"
            }
        }
    }
}
