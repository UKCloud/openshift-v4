#!/bin/bash

function get_config () {
  # function for getting config:
  # Eg:
  # get_config "sshpubkey"
  # get_config "svcs[0].hostname"
  cat /tmp/workingdir/config.json | jq .$1
}

############
# Scale script for stage2
############

TAG=$( get_config "imagetag" )

## INPUTS: config.json, secrets.json (in /home/core/deployconfig on bastion)
# Run "3.setup-bastion/Dockerfile"
sudo podman run  -v ~/deployconfig:/tmp/workingdir:z 3.setup-bastion:${TAG}
## OUTPUTS: ansible-hosts (for ansible post deploy task), install-config.yaml (for installer)


## INPUTS: config.json secrets.json
# Run "7.terraform-deploy/Dockerfile"
sudo podman run -v ~/deployconfig:/tmp/workingdir:z 7.terraform-deploy:${TAG}
## OUTPUTS: VMs are created. terraform.tfstate

## INPUTS: ansible-hosts from stage 3,
# Run "8.post-deployment/Dockerfile"
sudo podman run  -v ~/deployconfig:/tmp/workingdir:z 8.post-deployment:${TAG}
## OUTPUTS: VMs are configured for DNS (so OpenShift initialisation can proceed)


