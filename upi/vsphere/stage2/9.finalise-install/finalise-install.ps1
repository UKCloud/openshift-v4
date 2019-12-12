## Finalise Install
##  - Remove bootstrap from LB pools
##  - Change 6443 API monitor to HTTPS type

Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:$false

$ClusterConfig = Get-Content -Raw -Path /tmp/workingdir/config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path /tmp/workingdir/secrets.json | ConvertFrom-Json

$vcenterIp = $ClusterConfig.vsphere.vsphere_server
$vcenterUser = $SecretConfig.vcenterdeploy.username
$vcenterPassword = $SecretConfig.vcenterdeploy.password


# Declare essential parameters
$transportZoneName = $ClusterConfig.vsphere.vsphere_transportzone
$edgeInternalIp = $ClusterConfig.loadbalancer.internalvip
$edgeExternalIp = $ClusterConfig.loadbalancer.externalvip
$edgeName = $ClusterConfig.vsphere.vsphere_edge
$masterIps = @($ClusterConfig.masters[0].ipaddress,$ClusterConfig.masters[1].ipaddress,$ClusterConfig.masters[2].ipaddress)
$infraIps = @($ClusterConfig.infras[0].ipaddress,$ClusterConfig.infras[1].ipaddress)
$bootstrapIp = $ClusterConfig.bootstrap.ipaddress
$snmask = $ClusterConfig.network.maskprefix

# Globals to allow templating engine to work:
$global:defaultgw = $ClusterConfig.network.defaultgw
$global:dnsip = $ClusterConfig.svcs[0].ipaddress

# connect to the vcenter/nsx with SSO
Connect-NsxServer -vCenterServer $vcenterIp -username $vcenterUser -password $vcenterPassword

# Obtain LB object
$loadbalancer = $edge | Get-NsxLoadBalancer

# create application profile 
#$appProfile = $loadbalancer | New-NsxLoadBalancerApplicationProfile -Type TCP -Name "tcp-source-persistence" -PersistenceMethod sourceip

# get the monitors needed for the pools
$tcpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_tcp_monitor
$httpsMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_https_monitor
$httpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_http_monitor

#$masterPoolApi = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name master-pool-6443 -Description "Master Servers Pool for cluster API" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
#$masterPoolMachine = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name master-pool-22623 -Description "Master Servers Pool for machine API" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
#$infraHttpsPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name infra-https-pool -Description "Infrastructure HTTPS Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
#$infraHttpPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name infra-http-pool -Description "Infrastructure HTTP Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor

# add members from the member variables to the pools
#for ( $index = 0; $index -lt $masterIps.Length ; $index++ )
#{
#    $masterPoolApi = $masterPoolApi | Add-NsxLoadBalancerPoolMember -Name master-$index -IpAddress $masterIps[$index] -Port 6443
#}
#$masterPoolApi = $masterPoolApi | Add-NsxLoadBalancerPoolMember -Name bootstrap-0 -IpAddress $bootstrapIp -Port 6443
#
#for ( $index = 0; $index -lt $masterIps.Length ; $index++ )
#{
#    $masterPoolMachine = $masterPoolMachine | Add-NsxLoadBalancerPoolMember -Name master-$index -IpAddress $masterIps[$index] -Port 22623
#}
#$masterPoolMachine = $masterPoolMachine | Add-NsxLoadBalancerPoolMember -Name bootstrap-0 -IpAddress $bootstrapIp -Port 22623
#
#for ( $index = 0; $index -lt $infraIps.Length ; $index++ )
#{
#    $infraHttpsPool = $infraHttpsPool | Add-NsxLoadBalancerPoolMember -Name infra-$index -IpAddress $infraIps[$index] -Port 443
#}
#
#for ( $index = 0; $index -lt $infraIps.Length ; $index++ )
#{
#    $infraHttpPool = $infraHttpPool | Add-NsxLoadBalancerPoolMember -Name infra-$index -IpAddress $infraIps[$index] -Port 80
#}

# create loadbalancer
#Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-6443 -Description "Cluster API port 6443" -IpAddress $edgeExternalIp -Protocol TCP -Port 6443 -DefaultPool $masterPoolApi -Enabled -ApplicationProfile $appProfile
#Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-int-6443 -Description "Cluster API port for internal 6443" -IpAddress $edgeInternalIp -Protocol TCP -Port 6443 -DefaultPool $masterPoolApi -Enabled -ApplicationProfile $appProfile
#Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-int-22623 -Description "Cluster Machine API port for internal 22623" -IpAddress $edgeInternalIp -Protocol TCP -Port 22623 -DefaultPool $masterPoolMachine -Enabled -ApplicationProfile $appProfile
#Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name application-traffic-https -Description "HTTPs traffic to application routes" -IpAddress $edgeExternalIp -Protocol TCP -Port 443 -DefaultPool $infraHttpsPool -Enabled -ApplicationProfile $appProfile
#Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name application-traffic-http -Description "HTTP traffic to application routes" -IpAddress $edgeExternalIp -Protocol TCP -Port 80 -DefaultPool $infraHttpPool -Enabled -ApplicationProfile $appProfile

