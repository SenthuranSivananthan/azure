Login-AzureRmAccount


$DateFormat = Get-Date -Format o | foreach {$_ -replace ":", "."}
Get-AzureRmResource | Export-Csv "c:\temp\AzureResourceExtract-$DateFormat.csv"
