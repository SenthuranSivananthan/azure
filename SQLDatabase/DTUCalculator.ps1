$PerfDataDirectory = Read-Host -Prompt "Enter the directory for Performance Counter data"
$CoreMappingFile = Read-Host -Prompt "CSV file with the Server to Core mapping"
$OutputDirectory = Read-Host -Prompt "Output Directory for the results"

$RestAPI = "http://dtucalculator.azurewebsites.net/api/calculate?cores="

$CoreMapping = Import-Csv $CoreMappingFile | Group-Object -AsHashTable -Property "Name"
$OutputDirectory = $OutputDirectory + "\\" + (Get-Date -format yyyyMMdd-HHmmss)

New-Item -Path $OutputDirectory -ItemType Directory -Force

$RecommendationOutputFile = $OutputDirectory + "\\Recommendations.csv" 

Class Recommendation
{
    [String]$Server
    [int]$Cores

    [String]$CPUServiceTier
    [double]$CPUServiceTierCoveragePct

    [String]$IopsServiceTier
    [double]$IopsServiceTierCoveragePct

    [String]$LogServiceTier
    [double]$LogServiceTierCoveragePct

    [String]$RecommendedServiceTier
    [double]$RecommendedServiceTierCoveragePct
}

$Recommendations = New-Object "System.Collections.ArrayList"

Get-ChildItem $PerfDataDirectory -Filter *.csv | Foreach-Object {
    Write-Output "Processing $_"

    $Server = $CoreMapping[$_.BaseName]

    if($Server -eq $null)
    {
        Write-Error "Can not find # of cores for file $_"
    }
    else
    {
        $json = Import-Csv $_.FullName | ConvertTo-Json

        $ApiCallUrl = $RestAPI + $Server.Cores

        $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $Headers.Add("Content-Type", 'application/json')
        $Headers.Add("Accept", 'application/json')

        $OutputFileName = $OutputDirectory + "\\" + $_.BaseName + "_dtu.json"

        # Save the raw output
        Invoke-RestMethod -Method Post -Uri $ApiCallUrl -Body $json -Headers $Headers -OutFile $OutputFileName

        # Read the output and append the recommendations
        $Results = Get-Content $OutputFileName | ConvertFrom-Json

        $r = New-Object Recommendation
        $r.Server = $_.BaseName
        $r.Cores = [int]"$Cores"
        Foreach ($Feature in $Results.Recommendations)
        {
            if ($Feature.Metric -ieq "CPU")
            {
	            $r.CPUServiceTier = $Feature.ServiceTier
                $r.CPUServiceTierCoveragePct = $Feature.ServiceTierCoveragePct
            }
            elseif ($Feature.Metric -ieq "IOPS")
            {
	            $r.IopsServiceTier = $Feature.ServiceTier
                $r.IopsServiceTierCoveragePct = $Feature.ServiceTierCoveragePct
            }
            elseif ($Feature.Metric -ieq "Log")
            {
	            $r.LogServiceTier = $Feature.ServiceTier
                $r.LogServiceTierCoveragePct = $Feature.ServiceTierCoveragePct
            }
            elseif ($Feature.Metric -ieq "Total")
            {
	            $r.RecommendedServiceTier = $Feature.ServiceTier
                $r.RecommendedServiceTierCoveragePct = $Feature.ServiceTierCoveragePct
            }
        }

        $Recommendations.Add($r)
    }
}

$Recommendations | Export-Csv -Path $RecommendationOutputFile
