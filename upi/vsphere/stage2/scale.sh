#!/bin/bash

function get_config () {
  # function for getting config:
  # Eg:
  # get_config "sshpubkey"
  # get_config "svcs[0].hostname"
  cat ~/deployconfig/config.json | jq .$1
}

############
# Scale script for stage2
############
TAG=$( get_config "imagetag" )

echo "This will scale the cluster according to the contents of config.json: Update this first"
echo " - 1) Edit config.json to add/remove the nodes"
echo " - 2) If removing a node, drain and delete the node in OpenShift"
echo " - 3) Press any key to continue and finalise the scale of the cluster"
echo ""
echo "This will use container version ${TAG} - Press any key to continue and Ctrl-C to abort"

read -n1 -s

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


