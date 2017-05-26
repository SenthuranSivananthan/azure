workflow Ping
{
    param  
    (  
        [Parameter(Mandatory=$true)]  
        [object] $WebhookData  
    )

    InlineScript
    {
        function SendEmail([string]$VMName, [string]$Status)
        {
            $SMTPServer = Get-AutomationVariable -Name 'SMTPServer'
            $SMTPPort = Get-AutomationVariable -Name 'SMTPPort'
            $SMTPUsername = Get-AutomationVariable -Name 'SMTPUsername'
            $SMTPPassword = Get-AutomationVariable -Name 'SMTPPassword'

            $PingAlertFrom = Get-AutomationVariable -Name 'PingAlertFrom'
            $PingAlertTo = Get-AutomationVariable -Name 'PingAlertTo'

            $Subject = "VM Status: " + $VMName + " - " + $Status

            $EmailCredentials = New-Object System.Management.Automation.PSCredential(
                                        $SMTPUsername,
                                        (ConvertTo-SecureString -String $SMTPPassword -AsPlainText -Force)
                                )

            Write-Output("Sending email to " + $PingAlertTo)


            Send-MailMessage `
                -from $PingAlertFrom `
                -to $PingAlertTo `
                -Subject $Subject `
                -Body $Subject `
                -Credential $EmailCredentials `
                -SmtpServer $SMTPServer `
                -usessl `
                -port $SMTPPort
        }

        $Computers = (ConvertFrom-Json $Using:WebhookData.RequestBody).SearchResults.value

        ForEach ($ComputerDescription in $Computers)
        {
            $PingOptions = New-Object net.NetworkInformation.PingOptions
            $PingOptions.set_ttl(64)
            $PingOptions.set_dontfragment($true)

            [Byte[]] $PingData = [System.Text.Encoding]::ASCII.GetBytes("PING")
            $Ping = new-object Net.NetworkInformation.Ping
            $ErrorActionPreference = "silentlycontinue"
            $PingResponse = $null
            $PingResponse = $Ping.send($ComputerDescription.Computer, 1000, $PingData, $PingOptions)

            if ($PingResponse -eq $null)
            {
                 Write-Output($ComputerDescription.Computer + ": No response")
                 SendEmail $ComputerDescription.Computer "No Response"
            }
            else
            {
                Write-Output($ComputerDescription.Computer + ": " + $PingResponse.status)

                if ($PingResponse.status -eq "Success")
                {
                    Write-Output($ComputerDescription.Computer + ": Reachable by Ping.")
                    SendEmail $ComputerDescription.Computer "Reachable by Ping"
                }
                else
                {
                    Write-Output($ComputerDescription.Computer + ": Unreachable by Ping.")
                    SendEmail $ComputerDescription.Computer "Unreachable by Ping"
                }
            }            
        }
    }
}