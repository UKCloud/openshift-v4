

############
# Placeholder sequencing script for stage1
############


## INPUTS: config.json, secrets.json
# Run "1.setup-env/Dockerfile", Container name: TBC
## OUTPUTS: (NSX: Virtual Network, VSE Interface, VSE DHCP, VSE Loadbalancer Config)

## INPUTS: config.json, secrets.json
# Run "2.create-bastion/Dockerfile", Container name: TBC 
## OUTPUTS: (vCenter: Bastion RHCOS VM with Network Adapter connected and correct Ignition to assign IP/SSH Key)
### TODO: Inject config.json, secrets.json into the VM?



