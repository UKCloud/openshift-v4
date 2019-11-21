`sudo podman build ./ -t 7.terraform-deploy:0.1
sudo podman run -v ~/deployconfig:/tmp/workingdir:z 7.terraform-deploy:0.1`



To destroy the deployment (delete all VMs):
`sudo podman run --entrypoint="/bin/terraform destroy -var-file=/tmp/workingdir/config.json -var-file=/tmp/workingdir/secrets.json  -state=/tmp/workingdir/terraform.tfstate -no-color -auto-approve`
