#!/bin/bash
# Script to locally build stage2 containers
echo "Enter the image tag version to build - this should be entered as \"imagetag\" in config.json:"
read TAG

echo "Enter the registry url prefix (without trailing /):"
read PREFIX

podman build --format=docker ./4.run-installer -t ${PREFIX}/4.run-installer:${TAG} --no-cache
podman build --format=docker ./5.ign-webserver -t ${PREFIX}/5.ign-webserver:${TAG} --no-cache
podman build --format=docker ./6.add-ignition -t ${PREFIX}/6.add-ignition:${TAG} --no-cache
podman build --format=docker ./7.terraform-deploy -t ${PREFIX}/7.terraform-deploy:${TAG} --no-cache
podman build --format=docker ./8.configure-svcs -t ${PREFIX}/8.configure-svcs:${TAG} --no-cache
podman build --format=docker ./9.post-deployment -t ${PREFIX}/9.post-deployment:${TAG} --no-cache

read -p "Press [Enter] to push images to registry, or [Ctrl-C] to cancel"

podman push --tls-verify=false ${PREFIX}/4.run-installer:${TAG}
podman push --tls-verify=false ${PREFIX}/5.ign-webserver:${TAG}
podman push --tls-verify=false ${PREFIX}/6.add-ignition:${TAG}
podman push --tls-verify=false ${PREFIX}/7.terraform-deploy:${TAG}
podman push --tls-verify=false ${PREFIX}/8.configure-svcs:${TAG}
podman push --tls-verify=false ${PREFIX}/9.post-deployment:${TAG}
