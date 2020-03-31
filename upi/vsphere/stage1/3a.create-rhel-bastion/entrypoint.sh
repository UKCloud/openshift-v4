#!/bin/sh
cd /usr/share/terraform
terraform apply -var-file=/tmp/workingdir/config.json -var-file=/tmp/workingdir/secrets.json  -state=/tmp/workingdir/terraform_bastion.tfstate -no-color -auto-approve
