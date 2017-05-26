$ResourceGroupName = "test-app-gw"
$Location = "eastus2"
$VNETName = "app-gw-vnet"
$DmzSubnet = "appgw"
$PipName = "appgw-pip"

$Domain1 = "farm1.senthuran.me"

$vnet = Get-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $ResourceGroupName -Verbose
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $DmzSubnet -VirtualNetwork $vnet -Verbose
$pip = Get-AzureRmPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName -Verbose

$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name app-gw-ip01 -Subnet $subnet

$pool1 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool01 -BackendIPAddresses 10.0.2.4
$pool2 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool02 -BackendIPAddresses 10.0.2.5
$pool3 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool03 -BackendIPAddresses 10.0.2.6
$pool4 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool04 -BackendIPAddresses 10.0.2.7

$probe1 = New-AzureRmApplicationGatewayProbeConfig -Name probe01 -Protocol Http -HostName localhost -Path "/c01" -Interval 30 -Timeout 30 -UnhealthyThreshold 5
$probe2 = New-AzureRmApplicationGatewayProbeConfig -Name probe02 -Protocol Http -HostName localhost -Path "/c02" -Interval 30 -Timeout 30 -UnhealthyThreshold 5
$probe3 = New-AzureRmApplicationGatewayProbeConfig -Name probe03 -Protocol Http -HostName localhost -Path "/c03" -Interval 30 -Timeout 30 -UnhealthyThreshold 5
$probe4 = New-AzureRmApplicationGatewayProbeConfig -Name probe04 -Protocol Http -HostName localhost -Path "/c04" -Interval 30 -Timeout 30 -UnhealthyThreshold 5

$poolSetting01 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting01" -Port 8080 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe1
$poolSetting02 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting02" -Port 8080 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe2
$poolSetting03 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting03" -Port 8080 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe3
$poolSetting04 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting04" -Port 8080 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe4

$fipconfig01 = New-AzureRmApplicationGatewayFrontendIPConfig -Name "frontend1-public" -PublicIPAddress $pip
$fp01 = New-AzureRmApplicationGatewayFrontendPort -Name "fep01" -Port 80

$listener01 = New-AzureRmApplicationGatewayHttpListener -Name "listener01" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -HostName $Domain1

$pathRule01 = New-AzureRmApplicationGatewayPathRuleConfig -Name "c01" -Paths "/c01/*" -BackendAddressPool $pool1 -BackendHttpSettings $poolSetting01
$pathRule02 = New-AzureRmApplicationGatewayPathRuleConfig -Name "c02" -Paths "/c02/*" -BackendAddressPool $pool2 -BackendHttpSettings $poolSetting02
$pathRule03 = New-AzureRmApplicationGatewayPathRuleConfig -Name "c03" -Paths "/c03/*" -BackendAddressPool $pool3 -BackendHttpSettings $poolSetting03
$pathRule04 = New-AzureRmApplicationGatewayPathRuleConfig -Name "c04" -Paths "/c04/*" -BackendAddressPool $pool4 -BackendHttpSettings $poolSetting04

$urlPathMap01 = New-AzureRmApplicationGatewayUrlPathMapConfig -Name "urlpathmap" -PathRules $pathRule01,$pathRule02,$pathRule03,$pathRule04 -DefaultBackendAddressPool $pool1 -DefaultBackendHttpSettings $poolSetting01

$rule01 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "urlPathMapRule01" -RuleType PathBasedRouting -HttpListener $listener01 -UrlPathMap $urlPathMap01

$sku = New-AzureRmApplicationGatewaySku -Name "Standard_Small" -Tier Standard -Capacity 1

$appgw = New-AzureRmApplicationGateway `
            -Name "app-gw" `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -BackendAddressPools $pool1,$pool2,$pool3,$pool4 `
            -BackendHttpSettingsCollection $poolSetting01,$poolSetting02,$poolSetting03,$poolSetting04 `
            -FrontendIpConfigurations $fipconfig01 `
            -GatewayIpConfigurations $gipconfig `
            -FrontendPorts $fp01 `
            -HttpListeners $listener01 `
            -RequestRoutingRules $rule01 `
            -UrlPathMaps $urlPathMap01 `
            -Probes $probe1,$probe2,$probe3,$probe4 `
            -Sku $sku

