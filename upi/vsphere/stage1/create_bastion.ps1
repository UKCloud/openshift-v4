
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
If ( ! (Get-module EPS )) {
 Install-Module EPS
}


Set-PowerCLIConfiguration -Scope User -Confirm:$false -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction:ignore -Confirm:$false

If ( ! (Get-module VMware.PowerCLI )) { 
 Install-Module VMware.PowerCLI
}

$ClusterConfig = Get-Content -Raw -Path ./config.json | ConvertFrom-Json
$SecretConfig = Get-Content -Raw -Path ./secrets.json | ConvertFrom-Json

$vcenterIp = $ClusterConfig.vsphere.vsphere_server
$vcenterUser = $SecretConfig.vcenterdeploy.username
$vcenterPassword = $SecretConfig.vcenterdeploy.password

# Output the object for a lark
write-host "Config Object: " ($ClusterConfig | Format-List | Out-String)

# Some experiments with arrays
write-host "clusterid: " $ClusterConfig.clusterid
write-host "bastion hostname: " $ClusterConfig.bastion.hostname
write-host "number of masters: " $ClusterConfig.masters.Count
write-host "second master name: " $ClusterConfig.masters[1].hostname

$bastion_ip = $ClusterConfig.bastion.ipaddress
$bastion_mask_prefix = $ClusterConfig.network.maskprefix
$bastion_dfgw = $ClusterConfig.network.defaultgw
$cluster_domain = ($ClusterConfig.clusterid + "." + $ClusterConfig.basedomain)
$bastion_dns1 = $ClusterConfig.network.upstreamdns1
$bastion_dns2 = $ClusterConfig.network.upstreamdns2
$bastion_hostname = $ClusterConfig.bastion.hostname

$id_rsa_pub = $ClusterConfig.sshpubkey

$ifcfg = Invoke-EpsTemplate -Path ./ifcfg.tmpl

$ifcfgbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ifcfg))

$hostnamebase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_hostname))

$bastion_ign = Invoke-EpsTemplate -Path ./bastion_ignition.tmpl
$bastion_ignbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_ign))

write-host -ForegroundColor cyan "Created base64: " $ifcfgbase64
write-host -ForegroundColor green "Created ignition: " $bastion_ign

Connect-VIServer –Server $vcenterIp -username $vcenterUser -password $vcenterPassword

$portgroup = Get-VDPortgroup -Name $ClusterConfig.vsphere.vsphere_network

$template = Get-VM -Name $ClusterConfig.vsphere.rhcos_template
$datastore = Get-Datastore -Name $ClusterConfig.vsphere.vsphere_datastore
$resourcePool = Get-Cluster -Name $ClusterConfig.vsphere.vsphere_cluster ### Temporary! This needs to be modified to point to a resource pool, probably precreated in vCloud?

$vm = New-VM -Name $bastion_hostname -VM $template -Datastore $datastore -ResourcePool $resourcePool -confirm:$false
$vm | Set-VM -NumCpu 1 -MemoryGB 2 -confirm:$false
$vm | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $portgroup -confirm:$false
$vm | New-AdvancedSetting -Name "guestinfo.ignition.config.data" -Value $bastion_ignbase64 -confirm:$false
$vm | New-AdvancedSetting -Name "guestinfo.ignition.config.data.encoding" -Value "base64" -confirm:$false
$vm | New-AdvancedSetting -Name "disk.EnableUUID" -Value "TRUE" -confirm:$false
