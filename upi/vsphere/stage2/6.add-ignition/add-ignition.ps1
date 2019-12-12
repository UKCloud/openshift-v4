###########################################################################
# Add Ignition information to JSON config file
# takes 7 command line options: 6 file names (in current dir)
# svc.ign file is created
###########################################################################
param (
    # Define command-line parameters
    [string]$inputfile = "config.json",
    [string]$outputfile = "config.json",
    [string]$masterign = "master.ign",
    [string]$workerign = "worker.ign",
    [string]$infraign = "infra.ign",
    [string]$svcign = "svc.ign"
)



# Read in the configs
try
{
 $ClusterConfig = Get-Content -Raw -Path $inputfile | ConvertFrom-Json
}
catch
{
 Write-Output "config.json cannot be parsed"
 Exit
}

# Create svc.ign
$global:sshpubkey = $ClusterConfig.sshpubkey
$global:installca = (Get-Content -Raw -Path $workerign | ConvertFrom-Json).ignition.security.tls.certificateAuthorities[0].source
$svcigndata = Invoke-EpsTemplate -Path /usr/local/6.add-ignition/svc.ign.tmpl
Out-File -FilePath /tmp/workingdir/svc.ign -InputObject $svcigndata
$ClusterConfig.ignition.svc_ignition = $(Get-Content -Raw -Path $svcign | ConvertTo-Json | ConvertFrom-Json).value 

# Process master.ign
$ClusterConfig.ignition.master_ignition = $(Get-Content -Raw -Path $masterign | ConvertTo-Json | ConvertFrom-Json).value

# Process worker.ign
$ClusterConfig.ignition.worker_ignition = $(Get-Content -Raw -Path $workerign | ConvertTo-Json | ConvertFrom-Json).value

# Process infra.ign
$ClusterConfig.ignition.infra_ignition = $(Get-Content -Raw -Path $infraign | ConvertTo-Json | ConvertFrom-Json).value


# Add Bootstrap URL
$bootstrapurl = "http://" + $ClusterConfig.bastion.ipaddress + "/bootstrap.ign"
$ClusterConfig.ignition.bootstrap_ignition_url = $bootstrapurl

# Backup config.json
Copy-Item ("./" + $inputfile) -Destination ("./." + $inputfile + ".add-ignbak")

# Write out config.json
$ClusterConfig | ConvertTo-Json | Out-File $outputfile
