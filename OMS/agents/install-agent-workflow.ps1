workflow install-oms-agent
{
    Param
    (
        [Parameter(mandatory=$true)]
        [String] $OMSWorkspaceId,

        [Parameter(mandatory=$true)]
        [String] $OMSWorkspaceKey,

        [Parameter(mandatory=$true)]
        [boolean] $DryRun
    )

    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID

    $Settings = @{"workspaceId"=$OMSWorkspaceId};
    $ProtectedSettings = @{"workspaceKey"=$OMSWorkspaceKey};

    if ($DryRun -eq $true)
    {
        Write-Output("This script was executed in Dry Run mode.  OMS Extension will not be installed.")
    }

    $ResourceGroupList = Get-AzureRmResourceGroup -Verbose
    ForEach -Parallel ($ResourceGroupName in $ResourceGroupList.ResourceGroupName)
    {
        InlineScript 
        {
            $ResourceGroupName = $Using:ResourceGroupName
            $Settings = $Using:Settings
            $ProtectedSettings = $Using:ProtectedSettings

            $DryRun = $Using:DryRun

            $OMSNewInstallCount = 0

            $VMList = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue -Verbose

            ForEach ($VM in $VMList)
            {
                $IsVMExtensionInstalled = Get-AzureRmVMExtension `
                                                -ResourceGroupName $Using:ResourceGroupName `
                                                -VMName $Using:VM.Name `
                                                -Name MicrosoftMonitoringAgent `
                                                -ErrorAction SilentlyContinue `
                                                -WarningAction SilentlyContinue

                if ($IsVMExtensionInstalled -eq $null)
                {
                    $VMPowerState = $VM | Get-AzureRmVM -Status -WarningAction SilentlyContinue | Select -ExpandProperty Statuses | ?{ $_.Code -match "PowerState" } | Select -ExpandProperty DisplayStatus

                    if ($VMPowerState -eq "VM running")
                    {
                        if ($VM.StorageProfile.OsDisk.OsType -eq "Windows")
                        {
                            if ($DryRun -eq $false)
                            {
                                Write-Output("Installing OMS agent on Windows Server: " + $ResourceGroupName + " / " + $VM.Name)

                                Set-AzureRmVMExtension `
                                        -ExtensionType MicrosoftMonitoringAgent `
                                        -Name MicrosoftMonitoringAgent `
                                        -Publisher Microsoft.EnterpriseCloud.Monitoring `
                                        -ResourceGroupName $ResourceGroupName `
                                        -TypeHandlerVersion 1.0 `
                                        -VMName $VM.Name `
                                        -Location $VM.Location `
                                        -ProtectedSettings $ProtectedSettings `
                                        -Settings $Settings `
                                        -Verbose
                            }

                            $OMSNewInstallCount++
                        }
                        else
                        {
                            if ($DryRun -eq $false)
                            {
                                Write-Output("Installing OMS agent on Linux Server: " + $ResourceGroupName + " / " + $VM.Name)

                                Set-AzureRmVMExtension `
                                        -ExtensionType OmsAgentForLinux `
                                        -Name OmsAgentForLinux `
                                        -Publisher Microsoft.EnterpriseCloud.Monitoring `
                                        -ResourceGroupName $ResourceGroupName `
                                        -TypeHandlerVersion 1.0 `
                                        -VMName $VM.Name `
                                        -Location $VM.Location `
                                        -ProtectedSettings $ProtectedSettings `
                                        -Settings $Settings `
                                        -Verbose
                            }
                            
                            $OMSNewInstallCount++
                        }
                    }
                }
            }

            if ($OMSNewInstallCount -gt 0)
            {
                if ($DryRun -eq $true)
                {
                    Write-Output("Status for " + $ResourceGroupName + ": OMS Extension needed on " + $OMSNewInstallCount + " VM(s)")
                }
                else
                {
                    Write-Output("Status for " + $ResourceGroupName + ": OMS Extension installed on " + $OMSNewInstallCount + " VM(s)")
                }
            }
            else
            {
                Write-Output("Status for " + $ResourceGroupName + ": No changes")
            }
        }
    }

    Write-Output("Finished checking VMs")
}
