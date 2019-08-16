###########################################################################
# This generates ignition for the Bastion
# and then creates and configures the VM
###########################################################################
# Inputs are from ./config.json, 
# username/passiword for vCenter is from ./secrets.json
###########################################################################

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module EPS

Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:$false
Install-Module VMware.PowerCLI

# Read in the configs
$ClusterConfig = Get-Content -Raw -Path ./config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path ./secrets.json | ConvertFrom-Json

$vcenterIp = $ClusterConfig.vsphere.vsphere_server
$vcenterUser = $SecretConfig.vcenterdeploy.username
$vcenterPassword = $SecretConfig.vcenterdeploy.password

# Some experiments with arrays
write-host "clusterid: " $ClusterConfig.clusterid
write-host "bastion hostname: " $ClusterConfig.bastion.hostname
write-host "number of masters: " $ClusterConfig.masters.Count
write-host "second master name: " $ClusterConfig.masters[1].hostname

# Extract some vars - not really needed but ...
$bastion_ip = $ClusterConfig.bastion.ipaddress
$bastion_mask_prefix = $ClusterConfig.network.maskprefix
$bastion_dfgw = $ClusterConfig.network.defaultgw
$cluster_domain = ($ClusterConfig.clusterid + "." + $ClusterConfig.basedomain)
$bastion_dns1 = $ClusterConfig.network.upstreamdns1
$bastion_dns2 = $ClusterConfig.network.upstreamdns2
$bastion_hostname = $ClusterConfig.bastion.hostname

$id_rsa_pub = $ClusterConfig.sshpubkey

# Generate the ifcfg script and convert to base64
$ifcfg = Invoke-EpsTemplate -Path ./ifcfg.tmpl
$ifcfgbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ifcfg))

$hostnamebase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_hostname))

# Generate the Ignition config and convert to base64
$bastion_ign = Invoke-EpsTemplate -Path ./bastion_ignition.tmpl
$bastion_ignbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_ign))

write-host -ForegroundColor green "Created ignition: " $bastion_ign

# Connect to vCenter
Connect-VIServer –Server $vcenterIp -username $vcenterUser -password $vcenterPassword

# Generate objects needed for VM creation and config
$portgroup = Get-VDPortgroup -Name $ClusterConfig.vsphere.vsphere_network
$template = Get-VM -Name $ClusterConfig.vsphere.rhcos_template
$datastore = Get-Datastore -Name $ClusterConfig.vsphere.vsphere_datastore
$resourcePool = Get-ResourcePool -Name $ClusterConfig.vsphere.vsphere_resourcepool
$folder = Get-Folder -Name $ClusterConfig.vsphere.vsphere_folder

# Create VM, cloning an existing VM
$vm = New-VM -Name $bastion_hostname -VM $template -Location $folder -Datastore $datastore -ResourcePool $resourcePool -confirm:$false

# Change config on VM including setting ignition as a property
$vm | Set-VM -NumCpu 1 -MemoryGB 2 -confirm:$false
$vm | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $portgroup -confirm:$false
$vm | New-AdvancedSetting -Name "guestinfo.ignition.config.data" -Value $bastion_ignbase64 -confirm:$false
$vm | New-AdvancedSetting -Name "guestinfo.ignition.config.data.encoding" -Value "base64" -confirm:$false
$vm | New-AdvancedSetting -Name "disk.EnableUUID" -Value "TRUE" -confirm:$false

# Power on the new VM
$vm | Start-VM -confirm:$false
