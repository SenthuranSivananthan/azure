$ResourceGroups = Get-AzureRmResourceGroup

Write-Host("Checking, please wait")
foreach ($ResourceGroup in $ResourceGroups)
{
    $Disks = Get-AzureRmDisk -ResourceGroupName $ResourceGroup.ResourceGroupName `
                | Where { $_.OwnerId -eq $null }
    
    foreach ($Disk in $Disks)
    {
        Write-Host($ResourceGroup.ResourceGroupName + " - " + $Disk.Name)
    }
}
Write-Host("Done")