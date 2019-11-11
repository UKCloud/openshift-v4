###########################################################################
# Add Ignition information to JSON config file
# takes 7 command line options: 6 file paths and a URL
###########################################################################
param (
    # Define command-line parameters
    [string]$inputfile = "config.json",
    [string]$outputfile = "config.json",
    [string]$masterign = "master.ign",
    [string]$workerign = "worker.ign",
    [string]$infraign = "infra.ign",
    [string]$svcign = "svc.ign",
    # [string]$bootstrapurl = "https://example.com/file"
)



# Read in the configs
$ClusterConfig = Get-Content -Raw -Path $inputfile | ConvertFrom-Json

# Process master.ign
$ClusterConfig.ignition.master_ignition = $(Get-Content -Raw -Path $masterign | ConvertTo-Json | ConvertFrom-Json).value

# Process worker.ign
$ClusterConfig.ignition.worker_ignition = $(Get-Content -Raw -Path $workerign | ConvertTo-Json | ConvertFrom-Json).value

# Process infra.ign
$ClusterConfig.ignition.infra_ignition = $(Get-Content -Raw -Path $infraign | ConvertTo-Json | ConvertFrom-Json).value

# Process svc.ign
$ClusterConfig.ignition.svc_ignition = $(Get-Content -Raw -Path $svcign | ConvertTo-Json | ConvertFrom-Json).value

# Add Bootstrap URL
$bootstrapurl = "http://" + $ClusterConfig.bastion.ipaddress + "/bootstrap.ign"
$ClusterConfig.ignition.bootstrap_ignition_url = $bootstrapurl


# Backup config.json
Copy-Item ("./" + $inputfile) -Destination ("./" + $inputfile + ".bak")

$ClusterConfig | ConvertTo-Json | Out-File $outputfile
