###########################################################################
# This generates ignition for the Bastion
# and then creates and configures the VM
###########################################################################
# Inputs are from ./config.json,
# username/passiword for vCenter is from ./secrets.json
###########################################################################

# Read in the configs
$ClusterConfig = Get-Content -Raw -Path /tmp/workingdir/config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path /tmp/workingdir/secrets.json | ConvertFrom-Json

# Read vars from config file
$global:basedomain = $ClusterConfig.basedomain
$global:machinecidr = ($ClusterConfig.network.networkip + "/" + $ClusterConfig.network.maskprefix)
$global:vcenterserver = $ClusterConfig.vsphere.vsphere_server 
$global:vcenterdatacenter = $ClusterConfig.vsphere.vsphere_datacenter
$global:vsandatastore = $ClusterConfig.vsphere.vsphere_datastore
$global:sshpubkey = $ClusterConfig.sshpubkey

# Vars for Ansible hosts file
$global:clusterid = $ClusterConfig.clusterid
$global:masters = $ClusterConfig.masters

$global:sworkers = $ClusterConfig.smallworkers
$global:mworkers = $ClusterConfig.mediumworkers
$global:lworkers = $ClusterConfig.largeworkers
$global:aworkers = $ClusterConfig.assuredworkers
$global:eworkers = $ClusterConfig.elevatedworkers

$global:infras = $ClusterConfig.infras
$global:svcs = $ClusterConfig.svcs
$global:bootstrap = $ClusterConfig.bootstrap
$global:bastion = $ClusterConfig.bastion

$global:externalvip = $ClusterConfig.loadbalancer.externalvip
$global:internalvip = $ClusterConfig.loadbalancer.internalvip
$global:upstreamdns1 = $ClusterConfig.network.upstreamdns1
$global:upstreamdns2 = $ClusterConfig.network.upstreamdns2
$global:imagetag = $ClusterConfig.imagetag

# Read vars from secret file
$global:vcenteruser = $SecretConfig.vcentervolumeprovisioner.username
$global:vcenterpassword = $SecretConfig.vcentervolumeprovisioner.password
$global:pullsecret = $SecretConfig.rhpullsecret | ConvertTo-Json

if($ClusterConfig.useletsencrypt) {
  if($ClusterConfig.useletsencrypt -eq 'True') {
    $global:dnsusername = $SecretConfig.dns.username
    $global:dnsuserpassword = $SecretConfig.dns.password
    write-host -ForegroundColor green "Lets Encrypt: TRUE"
  }
}


# Code to check for custom registry ca
# Defaults to False
$global:addregistryca = 'False'
if($ClusterConfig.registryca) {
  if($ClusterConfig.registryca -ne '') {
    $global:registryca = $ClusterConfig.registryca
    $global:addregistryca = 'True'
  }
}

# Code to check for disconnected image sources
$global:addimagesources = 'False'
if($ClusterConfig.imagesources) {
  if($ClusterConfig.imagesources -ne '') {
    $global:imagesources = $ClusterConfig.imagesources
    $global:addimagesources = 'True'
  }
}


write-host -ForegroundColor green "Pull Secret: " $global:pullsecret 

# Invoke template to generate the ansible-hosts file
$ansiblehosts = Invoke-EpsTemplate -Path ./ansible-hosts.tmpl
write-host -ForegroundColor green "Ansible hosts: " $ansiblehosts
Out-File -FilePath /tmp/workingdir/ansible-hosts -InputObject $ansiblehosts
write-host -ForegroundColor green "Created ansible-hosts file"

# Invoke template to generate the install-config file
$installconfig = Invoke-EpsTemplate -Path ./install-config.tmpl
Out-File -FilePath /tmp/workingdir/install-config.yaml -InputObject $installconfig
write-host -ForegroundColor green "Created install-config.yaml file"

