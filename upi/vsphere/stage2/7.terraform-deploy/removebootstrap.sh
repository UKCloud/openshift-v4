cd /usr/share/terraform/
sed -i '/clusterid/a \
  "bootstrap_complete": "true",' /tmp/workingdir/config.json
terraform apply -var-file=/tmp/workingdir/config.json -var-file=/tmp/workingdir/secrets.json  -state=/tmp/workingdir/terraform.tfstate -no-color -auto-approve
