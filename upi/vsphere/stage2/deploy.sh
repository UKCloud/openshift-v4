############
Deploy script for stage2
############

TAG=0.1

## INPUTS: config.json, secrets.json (in /home/core/deployconfig on bastion)
# Run "3.setup-bastion/Dockerfile"
sudo podman run  -v ~/deployconfig:/tmp/workingdir:z 3.setup-bastion:${TAG}
## OUTPUTS: ansible-hosts (for ansible post deploy task), install-config.yaml (for installer)

## INPUTS: config.json, secrets.json install-config.yaml
# Run "4.run-installer/Dockerfile"
sudo podman run  -v ~/deployconfig:/tmp/workingdir:z 4.run-installer:${TAG}
## OUTPUTS: worker.ign bootstrap.ign master.ign

## INPUTS: bootstrap.ign
# Run "5.ign-webserver/Dockerfile"
sudo podman stop ign-webserver
sudo podman rm ign-webserver
sudo podman run --name ign-webserver -d -v ~/deployconfig/bootstrap.ign:/usr/share/nginx/html/bootstrap.ign:z --network host -p 80:80 5.ign-webserver:${TAG}
## OUTPUTS: none (container continues to run) Container serves the ign file from the bastions IP

## INPUTS: config.json worker.ign bootstrap.ign master.ign
# Run "6.add-ignition/Dockerfile"
sudo podman run -v ~/deployconfig:/tmp/workingdir:z 6.add-ignition:${TAG}
## OUTPUTS: config.json (updated with ign)

## INPUTS: config.json secrets.json
# Run "7.terraform-deploy/Dockerfile"
sudo podman run -v ~/deployconfig:/tmp/workingdir:z 7.terraform-deploy:${TAG}
## OUTPUTS: VMs are created. terraform.tfstate


# Wait a while for svcs machines to start..
echo "Waiting a minute or so for svcs VMs to start before DNS initialisation"
sleep 80


## INPUTS: ansible-hosts from stage 3,
# Run "7.terraform-deploy/Dockerfile"
sudo podman run  -v ~/deployconfig:/tmp/workingdir:z 9.post-deployment:${TAG}
## OUTPUTS: VMs are configured for DNS (so OpenShift initialisation can proceed)
