
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module EPS

#$vcenterIp = (get-item Env:vcenterip).value
#$vcenterUser = (get-item Env:vcenterUser).value
#$vcenterPassword = (get-item Env:vcenterPassword).value

$ClusterConfig = Get-Content -Raw -Path ./config.json | ConvertFrom-Json

write-host "Config Object: " ($ClusterConfig | Format-List | Out-String)

# Some experiments with arrays
write-host "clusterid: " $ClusterConfig.clusterid
write-host "bastion hostname: " $ClusterConfig.bastion.hostname
write-host "number of masters: " $ClusterConfig.masters.Count


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


write-host -ForegroundColor cyan "Created base64: " $ifcfgbase64
write-host -ForegroundColor green "Created ignition: " $bastion_ign
