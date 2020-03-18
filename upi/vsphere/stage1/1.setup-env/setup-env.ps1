Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:$false

# Read in the configs
try
{
 $ClusterConfig = Get-Content -Raw -Path /tmp/workingdir/config.json | ConvertFrom-Json
}
catch
{
 Write-Output "config.json cannot be parsed Is it valid JSON?"
 Exit
}

# Read in the secrets
try
{
 $SecretConfig = Get-Content -Raw -Path /tmp/workingdir/secrets.json | ConvertFrom-Json
}
catch
{
 Write-Output "secret.json cannot be parsed. Is it valid JSON?"
 Exit
}


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

######################################################
# IP address conversions                             #
######################################################
# Convert integer subnet mask to #.#.#.# format
$cidrbinary = ('1' * $snmask).PadRight(32, "0")
$octets = $cidrbinary -split '(.{8})' -ne ''
$global:longmask = ($octets | ForEach-Object -Process {[Convert]::ToInt32($_, 2) }) -join '.'
write-host -ForegroundColor cyan "Converted long SN mask: " $global:longmask

# Create IPAddress objects so we can calculate range
$dfgwip = [IPAddress] $global:defaultgw
$maskip = [IPAddress] $global:longmask
$netip = [IPAddress] ($dfgwip.Address -band $maskip.Address)

# Calculate 200th IP in our subnet
$startoffset = [IPAddress] "0.0.0.200"
$dhcpstartip = [IPAddress] "0"
$dhcpstartip.Address = $netip.Address + $startoffset.Address

# Calculated 249th IP in our subnet
$endoffset = [IPAddress] "0.0.0.249"
$dhcpendip = [IPAddress] "0"
$dhcpendip.Address = $netip.Address + $endoffset.Address

$global:dhcprange = $dhcpstartip.IPAddressToString + "-" + $dhcpendip.IPAddressToString
write-host -ForegroundColor cyan "DHCP Range: " $global:dhcprange
######################################################

$dhcpxmlobject = Invoke-EpsTemplate -Path ./dhcp-config.tmpl

write-host -ForegroundColor cyan "DHCP XML: " $dhcpxmlobject 


# connect to the vcenter/nsx with SSO
Connect-NsxServer -vCenterServer $vcenterIp -username $vcenterUser -password $vcenterPassword


# populate the edge variable with the appropriate edge
$edge = Get-NsxEdge $edgeName
write-host -ForegroundColor cyan "Using vSE: " $edgeName

# setup dhcp
$uri = "/api/4.0/edges/$($edge.id)/dhcp/config"
Invoke-NsxWebRequest -method "put"  -uri $uri -body $dhcpxmlobject -connection $nsxConnection

# setup a loadbalancer
# enable loadbalancer on the edge
$loadbalancer = $edge | Get-NsxLoadBalancer | Set-NsxLoadBalancer -Enabled -EnableLogging -EnableAcceleration

# create application profile 
$appProfile = $loadbalancer | New-NsxLoadBalancerApplicationProfile -Type TCP -Name "tcp-source-persistence" -PersistenceMethod sourceip

# create server pool
# get the monitors needed for the pools
try {
    $tcpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor -Name default_tcp_monitor
}
catch {
    Write-Error -Message "The monitor: default_tcp_monitor not found. Attempting to create it..."
    try {
        # Silently create default_tcp_monitor
        $tcpMonitor = $edge | Get-NsxLoadBalancer | New-NsxLoadBalancerMonitor -Name default_tcp_monitor -Interval 5 -Timeout 15 -MaxRetries 3 -TypeTCP 
        Write-Output -InputObject "Successfully created load balancer monitor: default_tcp_monitor"
    }
    catch {
        Write-Error -Message "Failed to create monitor: default_tcp_monitor" -ErrorAction "Stop"
    }
}

#$edge | Get-NsxLoadBalancer | New-NsxLoadBalancerMonitor -Name default_tcp_monitor -Interval 5 -Timeout 15 -MaxRetries 3 -Type TCP
#$tcpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_tcp_monitor


$masterPoolApi = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name master-pool-6443 -Description "Master Servers Pool for cluster API" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
$masterPoolMachine = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name master-pool-22623 -Description "Master Servers Pool for machine API" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor

# add members from the member variables to the pools
for ( $index = 0; $index -lt $masterIps.Length ; $index++ )
{
    $masterPoolApi = $masterPoolApi | Add-NsxLoadBalancerPoolMember -Name master-$index -IpAddress $masterIps[$index] -Port 6443
}
$masterPoolApi = $masterPoolApi | Add-NsxLoadBalancerPoolMember -Name bootstrap-0 -IpAddress $bootstrapIp -Port 6443

for ( $index = 0; $index -lt $masterIps.Length ; $index++ )
{
    $masterPoolMachine = $masterPoolMachine | Add-NsxLoadBalancerPoolMember -Name master-$index -IpAddress $masterIps[$index] -Port 22623
}
$masterPoolMachine = $masterPoolMachine | Add-NsxLoadBalancerPoolMember -Name bootstrap-0 -IpAddress $bootstrapIp -Port 22623

# create loadbalancer
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-6443 -Description "Cluster API port 6443" -IpAddress $edgeExternalIp -Protocol TCP -Port 6443 -DefaultPool $masterPoolApi -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-int-6443 -Description "Cluster API port for internal 6443" -IpAddress $edgeInternalIp -Protocol TCP -Port 6443 -DefaultPool $masterPoolApi -Enabled -ApplicationProfile $appProfile
Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name cluster-api-int-22623 -Description "Cluster Machine API port for internal 22623" -IpAddress $edgeInternalIp -Protocol TCP -Port 22623 -DefaultPool $masterPoolMachine -Enabled -ApplicationProfile $appProfile




##########################################################################
# Function to Create app LBs on additional Edges
function Add-App-LB {
  param( [string]$Zone )

  # Logic to allow for creating infra workers
  $Prefix = "worker-"
  if($Zone -eq "infra") {
    $Prefix = ""
  }

  # setup a loadbalancer
  # enable loadbalancer on the edge
  $loadbalancer = $edge | Get-NsxLoadBalancer | Set-NsxLoadBalancer -Enabled -EnableLogging -EnableAcceleration
  
  # create application profile
  $appProfile = $loadbalancer | New-NsxLoadBalancerApplicationProfile -Type TCP -Name "tcp-source-persistence" -PersistenceMethod sourceip
  
  # get the monitors needed for the pools
  try {
      Write-Output -InputObject "About to get tcpMonitor **********************"
      $tcpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor default_tcp_monitor
      write-host -ForegroundColor cyan "Inside Monitor object: " ($tcpMonitor | Format-Table | Out-String)
  }
  catch {
      Write-Error -Message "The monitor: default_tcp_monitor not found. Attempting to create it..."
      try {
          # Silently create default_tcp_monitor
          $tcpMonitor = $edge | Get-NsxLoadBalancer | New-NsxLoadBalancerMonitor -Name default_tcp_monitor -Interval 5 -Timeout 15 -MaxRetries 3 -TypeTCP
          Write-Output -InputObject "Successfully created load balancer monitor: default_tcp_monitor"
      }
      catch {
          Write-Error -Message "Failed to create monitor: default_tcp_monitor" -ErrorAction "Stop"
      }
  }

  Write-Output -InputObject "Trying again to gettcpMonitor *****************"
  $tcpMonitor = $edge | Get-NsxLoadBalancer | Get-NsxLoadBalancerMonitor -Name default_tcp_monitor  
  write-host -ForegroundColor cyan "Edge object: " ($edge | Format-Table | Out-String)
  write-host -ForegroundColor cyan "Edge name: " $edgeName
  $LBDiag = $edge | Get-NsxLoadBalancer
  write-host -ForegroundColor cyan "Loadbalancer: " ($LBDiag | Format-Table | Out-String) 
  $LBDiag = Get-NsxEdge $edgeName | Get-NsxLoadBalancer
  write-host -ForegroundColor cyan "Loadbalancer from name " ($LBDiag | Format-Table | Out-String)
  write-host -ForegroundColor cyan "Monitor object: " ($tcpMonitor | Format-Table | Out-String)
  Write-Output -InputObject "Done Trying again to gettcpMonitor *****************"

  $infraHttpsPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name $Zone-https-pool -Description "Infrastructure HTTPS Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor
  $infraHttpPool = Get-NsxEdge $edgeName | Get-NsxLoadBalancer | New-NsxLoadBalancerPool -Name $Zone-http-pool -Description "Infrastructure HTTP Servers Pool" -Transparent:$false -Algorithm round-robin -Monitor $tcpMonitor

  for ( $index = 0; $index -lt $infraIps.Length ; $index++ )
  {
      $infraHttpsPool = $infraHttpsPool | Add-NsxLoadBalancerPoolMember -Name $Prefix$Zone-$index -IpAddress $infraIps[$index] -Port 443
  }
  for ( $index = 0; $index -lt $infraIps.Length ; $index++ )
  {
      $infraHttpPool = $infraHttpPool | Add-NsxLoadBalancerPoolMember -Name $Prefix$Zone-$index -IpAddress $infraIps[$index] -Port 80
  }
  Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name $Zone-app-traffic-https -Description "HTTPS traffic to application routes" -IpAddress $edgeExternalIp -Protocol TCP -Port 443 -DefaultPool $infraHttpsPool -Enabled -ApplicationProfile $appProfile
  Get-NsxEdge $edgeName | Get-NsxLoadBalancer | Add-NsxLoadBalancerVip -Name $Zone-app-traffic-http -Description "HTTP traffic to application routes" -IpAddress $edgeExternalIp -Protocol TCP -Port 80 -DefaultPool $infraHttpPool -Enabled -ApplicationProfile $appProfile
}
# End function def
##########################################################################


# Create application LB on management edge if infra nodes exist
if($ClusterConfig.infras.Count -gt 0) {
  # All the necessary vars should be set at the start of the script
  write-host -ForegroundColor cyan "Infra App LB: Using vSE: " $edgeName
  Add-App-LB -Zone "infra"
}



# Create Assured Loadbalancers if assuredworkers exist
if($ClusterConfig.assured.vsphere_edge -ne $null -and $ClusterConfig.assured.vsphere_edge -ne $ClusterConfig.management.vsphere_edge -and $ClusterConfig.assuredworkers.Count -gt 0) {
  $edgeExternalIp = $ClusterConfig.assured.externalvip
  $edgeName = $ClusterConfig.assured.vsphere_edge
  $infraIps = @($ClusterConfig.assuredworkers.ipaddress)

  $edge = Get-NsxEdge $edgeName
  write-host -ForegroundColor cyan "Assured Edge object: " $edge
  write-host -ForegroundColor cyan "Assured: Using vSE: " $edgeName
  
  Add-App-LB -Zone "assured"
}


# Create AssuredPublic Loadbalancers if assuredpublicworkers exist
if($ClusterConfig.assured_public.vsphere_edge -ne $null -and $ClusterConfig.assured_public.vsphere_edge -ne $ClusterConfig.management.vsphere_edge -and $ClusterConfig.assuredpublicworkers.Count -gt 0) {
  $edgeExternalIp = $ClusterConfig.assured_public.externalvip
  $edgeName = $ClusterConfig.assured_public.vsphere_edge
  $infraIps = @($ClusterConfig.assuredpublicworkers.ipaddress)

  $edge = Get-NsxEdge $edgeName
  write-host -ForegroundColor cyan "Assured Public: Using vSE: " $edgeName
  
  Add-App-LB -Zone "assuredpub"
}


# Create Combined Loadbalancers if combinedworkers exist
if($ClusterConfig.combined.vsphere_edge -ne $null -and $ClusterConfig.combined.vsphere_edge -ne $ClusterConfig.management.vsphere_edge -and $ClusterConfig.combinedworkers.Count -gt 0) {
  $edgeExternalIp = $ClusterConfig.combined.externalvip
  $edgeName = $ClusterConfig.combined.vsphere_edge
  $infraIps = @($ClusterConfig.combinedworkers.ipaddress)

  $edge = Get-NsxEdge $edgeName
  write-host -ForegroundColor cyan "Combined: Using vSE: " $edgeName
  
  Add-App-LB -Zone "combined"
}



# Create Elevated Loadbalancers if elevatedworkers exist
if($ClusterConfig.elevated.vsphere_edge -ne $null -and $ClusterConfig.elevated.vsphere_edge -ne $ClusterConfig.management.vsphere_edge -and $ClusterConfig.elevatedworkers.Count -gt 0) {
  $edgeExternalIp = $ClusterConfig.elevated.externalvip
  $edgeName = $ClusterConfig.elevated.vsphere_edge
  $infraIps = @($ClusterConfig.elevatedworkers.ipaddress)

  $edge = Get-NsxEdge $edgeName
  write-host -ForegroundColor cyan "Elevated: Using vSE: " $edgeName
  
  Add-App-LB -Zone "elevated"
}


# Create ElevatedPublic Loadbalancers if elevatedpublicworkers exist
if($ClusterConfig.elevated_public.vsphere_edge -ne $null -and $ClusterConfig.elevated_public.vsphere_edge -ne $ClusterConfig.management.vsphere_edge -and $ClusterConfig.elevatedpublicworkers.Count -gt 0) {
  $edgeExternalIp = $ClusterConfig.elevated_public.externalvip
  $edgeName = $ClusterConfig.elevated_public.vsphere_edge
  $infraIps = @($ClusterConfig.elevatedpublicworkers.ipaddress)

  $edge = Get-NsxEdge $edgeName
  write-host -ForegroundColor cyan "Elevated Public: Using vSE: " $edgeName
  
  Add-App-LB -Zone "elevatedpub"
}

