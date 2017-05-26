$ResourceGroupName = "test-app-gw"
$Location = "eastus2"
$VNETName = "app-gw-vnet"
$DmzSubnet = "appgw"
$PipName = "app-gw-pip"

$Domain1 = "senthuran.me"
$Domain2 = "senthuran.me"

$vnet = Get-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $ResourceGroupName -Verbose
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $DmzSubnet -VirtualNetwork $vnet -Verbose
$pip = Get-AzureRmPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName -Verbose

$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name app-gw-ip01 -Subnet $subnet

$pool1 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool01 -BackendIPAddresses 10.4.1.4
$pool2 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool02 -BackendIPAddresses 10.4.1.5

$probe1 = New-AzureRmApplicationGatewayProbeConfig -Name probe01 -Protocol Http -HostName $Domain1 -Path "/" -Interval 30 -Timeout 30 -UnhealthyThreshold 5
$probe2 = New-AzureRmApplicationGatewayProbeConfig -Name probe02 -Protocol Http -HostName $Domain2 -Path "/" -Interval 30 -Timeout 30 -UnhealthyThreshold 5

$poolSetting01 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting01" -Port 9020 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe1
$poolSetting02 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting02" -Port 9020 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe2

$fipconfig01 = New-AzureRmApplicationGatewayFrontendIPConfig -Name "frontend1-public" -PublicIPAddress $pip
$fp01 = New-AzureRmApplicationGatewayFrontendPort -Name "fep01" -Port 80

$fipconfig02 = New-AzureRmApplicationGatewayFrontendIPConfig -Name "frontend1-private" -Subnet $subnet
$fp02 = New-AzureRmApplicationGatewayFrontendPort -Name "fep02" -Port 80

$listener01 = New-AzureRmApplicationGatewayHttpListener -Name "listener01" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -HostName $Domain1
$listener02 = New-AzureRmApplicationGatewayHttpListener -Name "listener02" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -HostName $Domain2

$listener03 = New-AzureRmApplicationGatewayHttpListener -Name "listener03" -Protocol Http -FrontendIPConfiguration $fipconfig02 -FrontendPort $fp02 -HostName $Domain1
$listener04 = New-AzureRmApplicationGatewayHttpListener -Name "listener04" -Protocol Http -FrontendIPConfiguration $fipconfig02 -FrontendPort $fp02 -HostName $Domain2

$rule01 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "rule01" -RuleType Basic -HttpListener $listener01 -BackendHttpSettings $poolSetting01 -BackendAddressPool $pool1
$rule02 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "rule02" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting02 -BackendAddressPool $pool2
$rule03 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "rule03" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting01 -BackendAddressPool $pool1
$rule04 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "rule04" -RuleType Basic -HttpListener $listener04 -BackendHttpSettings $poolSetting02 -BackendAddressPool $pool2

$sku = New-AzureRmApplicationGatewaySku -Name "Standard_Small" -Tier Standard -Capacity 1

$appgw = New-AzureRmApplicationGateway -Name "app-gw-2" -ResourceGroupName $ResourceGroupName -Location $Location -BackendAddressPools $pool1,$pool2 -BackendHttpSettingsCollection $poolSetting01, $poolSetting02 -FrontendIpConfigurations $fipconfig01,$fipconfig02 -GatewayIpConfigurations $gipconfig -FrontendPorts $fp01,$fp02 -HttpListeners $listener01,$listener02,$listener03,$listener04 -RequestRoutingRules $rule01,$rule02,$rule03,$rule04 -Probes $probe1,$probe2 -Sku $sku

