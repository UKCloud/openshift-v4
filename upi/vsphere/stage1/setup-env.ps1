sudo yum install https://github.com/PowerShell/PowerShell/releases/download/v6.2.0/powershell-6.2.0-1.rhel.7.x86_64.rpm


Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module VMware.PowerCLI,PowerNSX
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore

$vcenterIp = (get-item Env:vcenterip).value
$vcenterUser = (get-item Env:vcenterUser).value
$vcenterPassword = (get-item Env:vcenterPassword).value

# Declare essential parameters
$transportZoneName = "VXLAN-Transport"
$edgeInternalIp = "10.254.0.254"
$edgeExternalIp = "192.168.1.29"
$edgeName = "vse-FirstEdge (421fbe8e-0f5b-4d52-b705-a738885d9215)"
$masterIps = @("10.254.0.10","10.254.0.11","10.254.0.12")
$infraIps = @("10.254.0.20","10.254.0.21")

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
$sw = New-NsxLogicalSwitch -TransportZone $transportzone -Name openshift-testing -ControlPlaneMode UNICAST_MODE
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
