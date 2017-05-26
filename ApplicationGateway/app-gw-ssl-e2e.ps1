$ResourceGroupName = "demo-app-gateway"
$Location = "eastus"
$VNETName = "vnet"
$DmzSubnet = "dmz"

$AppGatewayName = "app-gw"
$PipName = $AppGatewayName + "-pip"

$Domain1 = "client1.senthuran.me"
$Domain2 = "client2.senthuran.me"

$Cert1Path = "c:\$Domain1.pfx"
$Cert2Path = "c:\$Domain2.pfx"

$ServerCert1Path = "c:\$Domain1.der"
$ServerCert2Path = "c:\$Domain2.der"

# Create Certificate
$CertPasswordText = "senthuran"
$CertPassword = ConvertTo-SecureString -String $CertPasswordText -Force –AsPlainText

$Cert1 = New-SelfSignedCertificate -DnsName $Domain1
Export-PfxCertificate -Password $CertPassword -Cert $Cert1 -FilePath $Cert1Path

$Cert2 = New-SelfSignedCertificate -DnsName $Domain2
Export-PfxCertificate -Password $CertPassword -Cert $Cert2 -FilePath $Cert2Path

$vnet = Get-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $ResourceGroupName -Verbose
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $DmzSubnet -VirtualNetwork $vnet -Verbose
$pip = Get-AzureRmPublicIpAddress -Name $PipName -ResourceGroupName $ResourceGroupName -Verbose

$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name app-gw-ip01 -Subnet $subnet

$pool1 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool01 -BackendIPAddresses 10.0.0.4
$pool2 = New-AzureRmApplicationGatewayBackendAddressPool -Name pool02 -BackendIPAddresses 10.0.0.5

$probe1 = New-AzureRmApplicationGatewayProbeConfig -Name probe01 -Protocol Https -HostName $Domain1 -Path "/" -Interval 30 -Timeout 30 -UnhealthyThreshold 5
$probe2 = New-AzureRmApplicationGatewayProbeConfig -Name probe02 -Protocol Https -HostName $Domain2 -Path "/" -Interval 30 -Timeout 30 -UnhealthyThreshold 5

$authcert1 = New-AzureRmApplicationGatewayAuthenticationCertificate -Name $Domain1 -CertificateFile $ServerCert1Path
$authcert2 = New-AzureRmApplicationGatewayAuthenticationCertificate -Name $Domain2 -CertificateFile $ServerCert2Path

$poolSetting01 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting01" -Port 9020 -Protocol Https -AuthenticationCertificates $authcert1 -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe1
$poolSetting02 = New-AzureRmApplicationGatewayBackendHttpSettings -Name "besetting02" -Port 9020 -Protocol Https -AuthenticationCertificates $authcert2 -CookieBasedAffinity Enabled -RequestTimeout 30 -Probe $probe2

$fipconfig01 = New-AzureRmApplicationGatewayFrontendIPConfig -Name "frontend1" -PublicIPAddress $pip
$fp01 = New-AzureRmApplicationGatewayFrontendPort -Name "fep01" -Port 443

$cert1 = New-AzureRmApplicationGatewaySslCertificate -Name $Domain1 -CertificateFile $Cert1Path -Password $CertPasswordText
$cert2 = New-AzureRmApplicationGatewaySslCertificate -Name $Domain2 -CertificateFile $Cert2Path -Password $CertPasswordText

$listener01 = New-AzureRmApplicationGatewayHttpListener -Name "listener01" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -HostName $Domain1 -SslCertificate $cert1
$listener02 = New-AzureRmApplicationGatewayHttpListener -Name "listener02" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -HostName $Domain2 -SslCertificate $cert2

$rule01 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "rule01" -RuleType Basic -HttpListener $listener01 -BackendHttpSettings $poolSetting01 -BackendAddressPool $pool1
$rule02 = New-AzureRmApplicationGatewayRequestRoutingRule -Name "rule02" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting02 -BackendAddressPool $pool2

$sku = New-AzureRmApplicationGatewaySku -Name "Standard_Small" -Tier Standard -Capacity 1

$appgw = New-AzureRmApplicationGateway -Name $AppGatewayName -ResourceGroupName $ResourceGroupName -Location $Location -BackendAddressPools $pool1,$pool2 -BackendHttpSettingsCollection $poolSetting01, $poolSetting02 -FrontendIpConfigurations $fipconfig01 -GatewayIpConfigurations $gipconfig -FrontendPorts $fp01 -HttpListeners $listener01, $listener02 -RequestRoutingRules $rule01, $rule02 -Probes $probe1,$probe2 -SslCertificates $cert1,$cert2 -AuthenticationCertificates $authcert1,$authcert2 -Sku $sku

