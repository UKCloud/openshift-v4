Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:$false

$ClusterConfig = Get-Content -Raw -Path ../config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path ../secrets.json | ConvertFrom-Json

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
$snmask = $ClusterConfig.network.maskprefix

# Globals to allow templating engine to work:
$global:defaultgw = $ClusterConfig.network.defaultgw
$global:dnsip = $ClusterConfig.svcs[0].ipaddress

# Convert integer subnet mask to #.#.#.# format
$cidrbinary = ('1' * $snmask).PadRight(32, "0")
$octets = $cidrbinary -split '(.{8})' -ne ''
$global:longmask = ($octets | ForEach-Object -Process {[Convert]::ToInt32($_, 2) }) -join '.'

write-host -ForegroundColor cyan "Converted long SN mask: " $global:longmask

# Elegant method?
[IPAddress] $ip = 0
$ip.Address = ([UInt32]::MaxValue -1) -shl (32 - $snmask) -shr (32 - $snmask)
$global:longmask = $ip.IPAddressToString  

write-host -ForegroundColor cyan "Converted long SN mask: " $global:longmask 

# Cheating a bit with DHCP Pool range; subnet will never be smaller than /24

Exit

# connect to the vcenter/nsx with SSO
Connect-NsxServer -vCenterServer $vcenterIp -username $vcenterUser -password $vcenterPassword

# populate the edge variable with the appropriate edge
$edge = Get-NsxEdge $edgeName
write-host -ForegroundColor cyan "Using vSE: " $edgeName

# create a network
# get the transport zone based on the name provided
$transportzone = Get-NsxTransportZone $transportZoneName 
write-host -ForegroundColor cyan "Using transport zone: " $transportzone.name

# create a new virtual network with in that transport zone
$sw = New-NsxLogicalSwitch -TransportZone $transportzone -Name $ClusterConfig.vsphere.vsphere_network -ControlPlaneMode UNICAST_MODE
write-host -ForegroundColor cyan "Created logical switch: " $sw.name

# attach the network to the vSE
$edge | Get-NsxEdgeInterface -Index 9 | Set-NsxEdgeInterface -Name vnic9 -Type internal -ConnectedTo $sw -PrimaryAddress $edgeInternalIp -SubnetPrefixLength 24

# setup dhcp
# You need an xml file with the config we want here...
$xmlobject = Get-Content ./dhcp-config.xml -raw
$uri = "/api/4.0/edges/$($edge.id)/dhcp/config"
Invoke-NsxWebRequest -method "put"  -uri $uri -body $xmlobject -connection $nsxConnection


# setup a loadbalancer
# enable loadbalancer on the edge
$loadbalancer = $edge | Get-NsxLoadBalancer | Set-NsxLoadBalancer -Enabled -EnableLogging -EnableAcceleration

# create application profile 
$appProfile = $loadbalancer | New-NsxLoadBalancerApplicationProfile -Type TCP -Name "tcp-source-persistence" -PersistenceMethod sourceip

# create server pool
# get the monitors needed for the pools
$tcpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_tcp_monitor
$httpsMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_https_monitor
$httpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_http_monitor

$masterPoolApi = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name master-pool-6443 -Description "Master Servers Pool for cluster API" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
$masterPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name master-pool-22623 -Description "Master Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
$infraHttpsPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name Infra-https-pool -Description "Infrastructure HTTPS Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $httpsMonitor
$infraHttpPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name Infra-http-pool -Description "Infrastructure HTTP Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $httpMonitor

# add members from the member variables to the pools
for ( $index = 0; $index -lt $masterIps.Length ; $index++ )
{
    $masterPoolApi = $masterPoolApi| Add-NsxLoadBalancerPoolMember -Name master-$index -IpAddress $masterIps[$index] -Port 6443
}

for ( $index = 0; $index -lt $masterIps.Length ; $index++ )
{
    $masterPool = $masterPool| Add-NsxLoadBalancerPoolMember -Name master-$index -IpAddress $masterIps[$index] -Port 22623
}

for ( $index = 0; $index -lt $infraIps.Length ; $index++ )
{
    $infraHttpsPool = $infraHttpsPool | Add-NsxLoadBalancerPoolMember -Name infra-$index -IpAddress $infraIps[$index] -Port 443
}

for ( $index = 0; $index -lt $infraIps.Length ; $index++ )
{
    $infraHttpPool = $infraHttpPool | Add-NsxLoadBalancerPoolMember -Name infra-$index -IpAddress $infraIps[$index] -Port 80
}

# create loadbalancer
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-6443 -Description "Cluster API port 6443" -IpAddress $edgeExternalIp -Protocol TCP -Port 6443 -DefaultPool $masterPoolApi -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-22623 -Description "Cluster API port 22623" -IpAddress $edgeExternalIp -Protocol TCP -Port 22623 -DefaultPool $masterPool -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-int-6443 -Description "Cluster API port for internal 6443" -IpAddress $edgeInternalIp -Protocol TCP -Port 6443 -DefaultPool $masterPoolApi -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-int-22623 -Description "Cluster API port for internal 22623" -IpAddress $edgeInternalIp -Protocol TCP -Port 22623 -DefaultPool $masterPool -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name application-traffic-https -Description "HTTPs traffic to application routes" -IpAddress $edgeExternalIp -Protocol TCP -Port 443 -DefaultPool $infraHttpsPool -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name application-traffic-http -Description "HTTP traffic to application routes" -IpAddress $edgeExternalIp -Protocol TCP -Port 80 -DefaultPool $infraHttpPool -Enabled -ApplicationProfile $appProfile
