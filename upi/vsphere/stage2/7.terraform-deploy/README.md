To destroy the deployment (delete all VMs, quickly, irreversably!):

`podman run --entrypoint="/bin/sh" -itv /home/core/deployconfig:/tmp/workingdir:z 7.terraform-deploy:<tagversion>`
`/bin/terraform destroy -var-file=/tmp/workingdir/config.json -var-file=/tmp/workingdir/secrets.json -state=/tmp/workingdir/terraform.tfstate -no-color -auto-approve`
