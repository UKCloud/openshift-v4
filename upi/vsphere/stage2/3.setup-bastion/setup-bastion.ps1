###########################################################################
# This generates ignition for the Bastion
# and then creates and configures the VM
###########################################################################
# Inputs are from ./config.json,
# username/passiword for vCenter is from ./secrets.json
###########################################################################

# Read in the configs
$ClusterConfig = Get-Content -Raw -Path ../config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path ../secrets.json | ConvertFrom-Json

# New code required to create install-config file

# Read vars from config file
$global:basedomain = $ClusterConfig.basedomain
$global:machinecidr = ($ClusterConfig.network.networkip + "/" + $ClusterConfig.network.maskprefix)
$global:vcenterserver = $ClusterConfig.vsphere.vsphere_server 
$global:vcenterdatacenter = $ClusterConfig.vsphere.vsphere_datacenter
$global:vsandatastore = $ClusterConfig.vsphere.vsphere_datastore
$global:sshpubkey = $ClusterConfig.sshpubkey

# Read vars from secret file
$global:vcenteruser = $SecretConfig.vcenterdeploy.username
$global:vcenterpassword = $SecretConfig.vcenterdeploy.password
$global:pullsecret = $SecretConfig.rhpullsecret

# Invoke template to generate the file
$installconfig = Invoke-EpsTemplate -Path ./install-config.tmpl

Out-File -FilePath ../install-config.yaml -InputObject $installconfig

write-host -ForegroundColor green "Created install-config file as required"

