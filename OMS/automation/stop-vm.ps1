workflow stop-vm
{
    Param
    (
        [Parameter(mandatory=$true)]
        [String] $ResourceGroupName,

        [Parameter(mandatory=$true)]
        [String] $VMName
    )

    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID

    Write-Output("Stopping VM - " + $VMName + " [" + $ResourceGroupName + "]")
    Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Verbose -Force
}