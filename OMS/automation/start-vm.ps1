workflow start-vm
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

    Write-Output("Starting VM - " + $VMName + " [" + $ResourceGroupName + "]")
    Start-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Verbose
}