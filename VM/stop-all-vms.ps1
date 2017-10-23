workflow stop-all-vms
{
    Param
    (
        [Parameter(mandatory=$true)]
        [String] $ResourceGroupName
    )

    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID

    $VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName
    
    ForEach -Parallel ($vm in $VMs)
    {
	Write-Output "Stopping: $($VM.Name)"
        Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Force -Verbose
    }

    Write-Output "All Done."
}