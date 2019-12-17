###########################################################################
# This generates ignition for the Bastion
# and then creates and configures the VM
###########################################################################
# Inputs are from ./config.json,
# username/passiword for vCenter is from ./secrets.json
###########################################################################

Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:$false

# Read in the configs
$ClusterConfig = Get-Content -Raw -Path /tmp/workingdir/config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path /tmp/workingdir/secrets.json | ConvertFrom-Json

$vcenterIp = $ClusterConfig.vsphere.vsphere_server
$vcenterUser = $SecretConfig.vcenterdeploy.username
$vcenterPassword = $SecretConfig.vcenterdeploy.password

# Some experiments with arrays
write-host "clusterid: " $ClusterConfig.clusterid
write-host "bastion hostname: " $ClusterConfig.bastion.hostname
write-host "bastion ip: " $ClusterConfig.bastion.ipaddress
write-host "number of masters: " $ClusterConfig.masters.Count
write-host "second master name: " $ClusterConfig.masters[1].hostname

# Extract some vars - not really needed but ...
$global:bastion_ip = $ClusterConfig.bastion.ipaddress
$global:bastion_mask_prefix = $ClusterConfig.network.maskprefix
$global:bastion_dfgw = $ClusterConfig.network.defaultgw
$global:cluster_domain = ($ClusterConfig.clusterid + "." + $ClusterConfig.basedomain)
$global:bastion_dns1 = $ClusterConfig.network.upstreamdns1
$global:bastion_dns2 = $ClusterConfig.network.upstreamdns2
$global:bastion_hostname = $ClusterConfig.bastion.hostname
$global:id_rsa_pub = $ClusterConfig.sshpubkey
$global:registryurl = $ClusterConfig.registryurl
$global:imagetag = $ClusterConfig.imagetag


try
{
 $global:sshprivkey = [Convert]::ToBase64String([IO.File]::ReadAllBytes('/tmp/workingdir/deploy.pem'))
}
catch
{
 Write-Output "deploy.pem needs to be in the /tmp/workingdir mount"
 Exit
}

# Generate the ifcfg script and convert to base64
$ifcfg = Invoke-EpsTemplate -Path ./ifcfg.tmpl

$global:ifcfgbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ifcfg))
write-host $ifcfg
write-host $ifcfgbase64

$stage2 = Invoke-EpsTemplate -Path ./stage2-containers.tmpl
$global:stage2base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($stage2))

$global:configbase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes('/tmp/workingdir/config.json'))
write-host $configbase64

$global:secretbase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes('/tmp/workingdir/secrets.json'))
write-host $secretbase64

$global:registryauthbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($SecretConfig.registrytoken))
write-host $SecretConfig.registrytoken
write-host $global:registryauthbase64

$global:hostnamebase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_hostname))
write-host $bastion_hostname
write-host $hostnamebase64


# Generate the Ignition config and convert to base64
$bastion_ign = Invoke-EpsTemplate -Path ./bastion-ignition.tmpl
$bastion_ignbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_ign))

write-host -ForegroundColor green "Created ignition: " $bastion_ign

# Connect to vCenter
Connect-VIServer –Server $vcenterIp -username $vcenterUser -password $vcenterPassword

# Generate objects needed for VM creation and config
#$portgroup = Get-VDPortgroup -Name $ClusterConfig.vsphere.vsphere_network
#$template = Get-VM -Name $ClusterConfig.vsphere.rhcos_template
$template = Get-Template -Name $ClusterConfig.vsphere.rhcos_template
$datastore = Get-Datastore -Name $ClusterConfig.vsphere.vsphere_datastore
$resourcePool = Get-ResourcePool -Name $ClusterConfig.vsphere.vsphere_resourcepool
$folder = Get-Folder -Name $ClusterConfig.vsphere.vsphere_folder

# Currently the portgroup name is obtained from NSX; this can cause problems when duplicate net names 
# are present in the vCenter
## DISABLED FOR PREDEPLOYED NETWORKS
$portgroup = $ClusterConfig.vsphere.vsphere_portgroup
#Connect-NsxServer -vCenterServer $vcenterIp -username $vcenterUser -password $vcenterPassword
#$sw = Get-NsxLogicalSwitch -name $ClusterConfig.vsphere.vsphere_network
#$virtualNetworkXml = [xml]$sw.outerxml
#$dvPortGroupId = $virtualNetworkXml.virtualWire.vdsContextWithBacking.backingValue
#$portgroup = Get-VDPortgroup | Where-Object {$_.key -eq $dvPortGroupId }

# Create VM, cloning an existing VM
$vm = New-VM -Name $bastion_hostname -Template $template -Location $folder -Datastore $datastore -ResourcePool $resourcePool -confirm:$false

# Change config on VM including setting ignition as a property
$vm | Set-VM -NumCpu 1 -MemoryGB 2 -confirm:$false
$vm | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $portgroup -confirm:$false
$vm | New-AdvancedSetting -Name "guestinfo.ignition.config.data" -Value $bastion_ignbase64 -confirm:$false
$vm | New-AdvancedSetting -Name "guestinfo.ignition.config.data.encoding" -Value "base64" -confirm:$false
$vm | New-AdvancedSetting -Name "disk.EnableUUID" -Value "TRUE" -confirm:$false

# Power on the new VM
$vm | Start-VM -confirm:$false
