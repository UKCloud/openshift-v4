cd /usr/share/terraform/
terraform plan -out=/tmp/workingdir/terraform.plan -var-file=/tmp/workingdir/config.json -var-file=/tmp/workingdir/secrets.json  -state=/tmp/workingdir/terraform.tfstate -no-color 
