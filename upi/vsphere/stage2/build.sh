#!/bin/bash
# Script to locally build stage2 containers
echo "Enter the image tag version to build:"
read TAG

echo "Enter the registry url prefix:"
read PREFIX

sudo podman build ./3.setup-bastion -t ${PREFIX}/3.setup-bastion:${TAG} --no-cache
sudo podman build ./4.run-installer -t ${PREFIX}/4.run-installer:${TAG} --no-cache
sudo podman build ./5.ign-webserver -t ${PREFIX}/5.ign-webserver:${TAG} --no-cache
sudo podman build ./6.add-ignition -t ${PREFIX}/6.add-ignition:${TAG} --no-cache
sudo podman build ./7.terraform-deploy -t ${PREFIX}/7.terraform-deploy:${TAG} --no-cache
sudo podman build ./8.post-deployment -t ${PREFIX}/8.post-deployment:${TAG} --no-cache
