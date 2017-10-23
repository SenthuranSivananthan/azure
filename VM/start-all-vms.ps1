workflow start-all-vms
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
	Write-Output "Starting: $($VM.Name)"
        Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vm.Name -Verbose
    }

    Write-Output "All Done."
}