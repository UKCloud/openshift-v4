

############
# Placeholder sequencing script for stage2
############


## INPUTS: config.json, secrets.json (in /home/core/deployconfig on bastion)
# Run "3.setup-bastion/Dockerfile", Container name: TBC
## OUTPUTS: ansible-hosts (for ansible post deploy task), install-config.yaml (for installer)

## INPUTS: config.json, secrets.json install-config.yaml
# Run "4.run-installer/Dockerfile", Container name: TBC 
## OUTPUTS: worker.ign bootstrap.ign master.ign

## INPUTS: bootstrap.ign 
# Run "5.ign-webserver/Dockerfile", Container name: TBC
## OUTPUTS: none (container continues to run) Container servers the ign file from the bastions IP 

## INPUTS: config.json worker.ign bootstrap.ign master.ign 
# Run "6.add-ignition/Dockerfile", Container name: TBC
## OUTPUTS: config.json (updated with ign)          

## INPUTS: config.json secrets.json
# Run "7.terraform-deploy/Dockerfile", Container name: TBC  
## OUTPUTS: VMs are created. terraform.plan and terraform.tfstate

## INPUTS: ansible-hosts from stage 3, 
# Run "7.terraform-deploy/Dockerfile", Container name: TBC                           
## OUTPUTS: VMs are configured for DNS, and configured for NTP (so OpenShift installation can proceed)
