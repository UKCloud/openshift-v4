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

# populate the edge variable with the appropriate edge
$edge = Get-NsxEdge $edgeName
write-host -ForegroundColor cyan "Using vSE: " $edgeName

# Obtain LB object
$loadbalancer = $edge | Get-NsxLoadBalancer

# create application profile
#$appProfile = $loadbalancer | New-NsxLoadBalancerApplicationProfile -Type TCP -Name "tcp-source-persistence" -PersistenceMethod sourceip

# Make a new Monitor and then get it redundantly to make sure we have it if it already exists
$apiMonitor = $edge | Get-NsxLoadBalancer | New-NsxLoadBalancerMonitor -Name openshift_6443_monitor  -Typehttps -interval 3 -Timeout 5 -maxretries 2 -Method GET -url "/healthz" -Expected "200" -Receive "ok"
$apiMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor openshift_6443_monitor

$masterPoolApi = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool master-pool-6443
$masterPoolMachine = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool master-pool-22623
$infraHttpsPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool infra-https-pool
$infraHttpPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool infra-http-pool

# Remove bootstrap machine from the Api pools

$apiBootstrapMember = $masterPoolApi | Get-NsxLoadBalancerPoolMember -Name "bootstrap-0"
Remove-NsxLoadBalancerPoolMember $apiBootstrapMember -Confirm:$false

$machineBootstrapMember = $masterPoolMachine | Get-NsxLoadBalancerPoolMember -Name "bootstrap-0"
Remove-NsxLoadBalancerPoolMember $machineBootstrapMember -Confirm:$false

# Change the monitor for 6443 API pool
$uri = "/api/4.0/edges/$($edge.id)/loadbalancer/config/pools/$($masterPoolApi.id)"
Write-Output -InputObject "Fetching monitor xml"
[xml]$poolxml = Invoke-NsxWebRequest -method "get" -uri $uri -connection $nsxConnection
# Replace pool monitorid with 
Write-Output -InputObject "Replacing monitor xml id: $($poolxml.pool.monitorId) with new id: $($apiMonitor.id)"
$poolxml.pool.monitorId = $apiMonitor.id
Invoke-NsxWebRequest -method "put" -uri $uri -body $poolxml -connection $nsxConnection

#$masterPoolApi = $masterPoolApi | Set-NsxLoadBalancerPool -Monitor $apiMonitor
## ^ Not clear how to do this, might need to make a new api pool then delete the old one after switch the vServer to using it.
