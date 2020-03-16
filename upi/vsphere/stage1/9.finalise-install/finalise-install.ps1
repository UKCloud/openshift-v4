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
### not actually essential?: $transportZoneName = $ClusterConfig.management.vsphere_transportzone
$edgeInternalIp = $ClusterConfig.management.internalvip
$edgeExternalIp = $ClusterConfig.management.externalvip
$edgeName = $ClusterConfig.management.vsphere_edge
$masterIps = @($ClusterConfig.masters[0].ipaddress,$ClusterConfig.masters[1].ipaddress,$ClusterConfig.masters[2].ipaddress)
$infraIps = @($ClusterConfig.infras[0].ipaddress,$ClusterConfig.infras[1].ipaddress)
$bootstrapIp = $ClusterConfig.bootstrap.ipaddress
$snmask = $ClusterConfig.vsphere.maskprefix

# Globals to allow templating to work:
$global:defaultgw = $ClusterConfig.management.defaultgw
if($ClusterConfig.svcs.Count -gt 0) {
  $global:dnsip = $ClusterConfig.svcs[0].ipaddress
}
elseif($ClusterConfig.combinedsvcs.Count -gt 0) {
  $global:dnsip = $ClusterConfig.combinedsvcs[0].ipaddress
}
else {
  write-host -ForegroundColor Red "No SVCs machines have been configured!"
}
write-host -ForegroundColor cyan "Default GW: " $global:defaultgw

# connect to the vcenter/nsx with SSO
Connect-NsxServer -vCenterServer $vcenterIp -username $vcenterUser -password $vcenterPassword

# populate the edge variable with the appropriate edge
$edge = Get-NsxEdge $edgeName
write-host -ForegroundColor cyan "Using vSE: " $edgeName

# Obtain LB object
$loadbalancer = $edge | Get-NsxLoadBalancer

# Make a new Monitor and then get it redundantly to make sure we have it if it already exists
write-host -ForegroundColor cyan "Making new Monitor:"
$apiMonitor = $edge | Get-NsxLoadBalancer | New-NsxLoadBalancerMonitor -Name openshift_6443_monitor  -Typehttps -interval 3 -Timeout 5 -maxretries 2 -Method GET -url "/healthz" -Expected "200" -Receive "ok"
$apiMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor -Name openshift_6443_monitor

write-host -ForegroundColor cyan "Created new monitor ID: " $apiMonitor.monitorId

$masterPoolApi = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool master-pool-6443
$masterPoolMachine = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Get-NsxLoadBalancerPool master-pool-22623

# Remove bootstrap machine from the Api pools

$apiBootstrapMember = $masterPoolApi | Get-NsxLoadBalancerPoolMember -Name "bootstrap-0"
Remove-NsxLoadBalancerPoolMember $apiBootstrapMember -Confirm:$false

$machineBootstrapMember = $masterPoolMachine | Get-NsxLoadBalancerPoolMember -Name "bootstrap-0"
Remove-NsxLoadBalancerPoolMember $machineBootstrapMember -Confirm:$false

# Change the monitor for 6443 API pool
$uri = "/api/4.0/edges/$($edge.id)/loadbalancer/config/pools/$($masterPoolApi.poolId)"
Write-Output -InputObject "Fetching monitor xml"
[xml]$poolxml = Invoke-NsxWebRequest -method "get" -uri $uri -connection $nsxConnection
# Replace pool monitorid with 6443 API pool
Write-Output -InputObject "Replacing monitor xml id: $($poolxml.pool.monitorId) with new id: $($apiMonitor.monitorId)"
$poolxml.pool.monitorId = $apiMonitor.monitorId
Write-Output -InputObject "Request body: $($poolxml.InnerXml)"
Invoke-NsxWebRequest -method "put" -uri $uri -body $poolxml.InnerXml -connection $nsxConnection
