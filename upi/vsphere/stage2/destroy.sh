echo "run the following to delete the deployment described by config.json (replace TAG with correct image tag):"
echo "sudo podman run --entrypoint="terraform destroy -var-file=/tmp/workingdir/config.json -var-file=/tmp/workingdir/secrets.json  -state=/tmp/workingdir/terraform.tfstate -no-color -auto-approve" -itv ~/deployconfig:/tmp/workingdir:z 7.terraform-deploy:TAG"
