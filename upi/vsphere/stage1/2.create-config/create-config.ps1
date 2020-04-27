###########################################################################
# This generates ignition for the Bastion
# and then creates and configures the VM
###########################################################################
# Inputs are from ./config.json,
# username/passiword for vCenter is from ./secrets.json
###########################################################################

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
 Write-Output "secrets.json cannot be parsed. Is it valid JSON?"
 Exit
}


# Read vars from config file
$global:basedomain = $ClusterConfig.basedomain
$global:machinecidr = ($ClusterConfig.vsphere.networkip + "/" + $ClusterConfig.vsphere.maskprefix)
$global:vcenterserver = $ClusterConfig.vsphere.vsphere_server 
$global:vcenterdatacenter = $ClusterConfig.vsphere.vsphere_datacenter
$global:defaultdatastore = $ClusterConfig.management.vsphere_datastore
$global:sshpubkey = $ClusterConfig.sshpubkey

# Vars for Ansible hosts file
$global:clusterid = $ClusterConfig.clusterid
$global:masters = $ClusterConfig.masters

$global:sworkers = $ClusterConfig.smallworkers
$global:mworkers = $ClusterConfig.mediumworkers
$global:lworkers = $ClusterConfig.largeworkers
$global:aworkers = $ClusterConfig.assuredworkers
$global:cworkers = $ClusterConfig.combinedworkers
$global:eworkers = $ClusterConfig.elevatedworkers
$global:apubworkers = $ClusterConfig.assuredpublicworkers
$global:epubworkers = $ClusterConfig.elevatedpublicworkers

$global:infras = $ClusterConfig.infras
$global:svcs = $ClusterConfig.svcs
$global:asvcs = $ClusterConfig.assuredsvcs
$global:csvcs = $ClusterConfig.combinedsvcs
$global:esvcs = $ClusterConfig.elevatedsvcs
$global:bootstrap = $ClusterConfig.bootstrap
$global:bastion = $ClusterConfig.bastion

$global:externalvip = $ClusterConfig.management.externalvip
$global:internalvip = $ClusterConfig.management.internalvip

$global:mupstreamdns1 = $ClusterConfig.management.upstreamdns1
$global:mupstreamdns2 = $ClusterConfig.management.upstreamdns2
$global:aupstreamdns1 = $ClusterConfig.assured.upstreamdns1
$global:aupstreamdns2 = $ClusterConfig.assured.upstreamdns2
$global:cupstreamdns1 = $ClusterConfig.combined.upstreamdns1
$global:cupstreamdns2 = $ClusterConfig.combined.upstreamdns2
$global:eupstreamdns1 = $ClusterConfig.elevated.upstreamdns1
$global:eupstreamdns2 = $ClusterConfig.elevated.upstreamdns2

$global:aingresscontrollername = $ClusterConfig.assured.ingresscontroller_name
$global:aingresscontrollerdomain = $ClusterConfig.assured.ingresscontroller_domain
$global:aingresscontrollerisdefault = $ClusterConfig.assured.ingresscontroller_isdefault.ToString().ToLower()
$global:apubingresscontrollername = $ClusterConfig.assured_public.ingresscontroller_name
$global:apubingresscontrollerdomain = $ClusterConfig.assured_public.ingresscontroller_domain
$global:apubingresscontrollerisdefault = $ClusterConfig.assured_public.ingresscontroller_isdefault.ToString().ToLower()
$global:cingresscontrollername = $ClusterConfig.combined.ingresscontroller_name
$global:cingresscontrollerdomain = $ClusterConfig.combined.ingresscontroller_domain
$global:cingresscontrollerisdefault = $ClusterConfig.combined.ingresscontroller_isdefault.ToString().ToLower()
$global:eingresscontrollername = $ClusterConfig.elevated.ingresscontroller_name
$global:eingresscontrollerdomain = $ClusterConfig.elevated.ingresscontroller_domain
$global:eingresscontrollerisdefault = $ClusterConfig.elevated.ingresscontroller_isdefault.ToString().ToLower()
$global:epubingresscontrollername = $ClusterConfig.elevated_public.ingresscontroller_name
$global:epubingresscontrollerdomain = $ClusterConfig.elevated_public.ingresscontroller_domain
$global:epubingresscontrollerisdefault = $ClusterConfig.elevated_public.ingresscontroller_isdefault.ToString().ToLower()

$global:satellitefqdn = $ClusterConfig.satellitefqdn
$global:rhnorgid = $ClusterConfig.rhnorgid
$global:rhnactivationkey = $ClusterConfig.rhnactivationkey

$global:rheltemplatepw = $SecretConfig.rheltemplatepw

$global:sshpubkey = $ClusterConfig.sshpubkey

$global:registryurl = $ClusterConfig.registryurl
$global:registryusername = $ClusterConfig.registryusername
$global:registrytoken = $SecretConfig.registrytoken
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
if($ClusterConfig.additionalca) {
  if($ClusterConfig.additionalca -ne '') {
    $global:registryca = $ClusterConfig.additionalca
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

