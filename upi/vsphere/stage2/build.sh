#!/bin/bash
# Script to locally build stage2 containers
echo "Enter the image tag version to build:"
TAG=$(read)

sudo podman build ./3.setup-bastion -t 3.setup-bastion:${TAG} --no-cache
sudo podman build ./4.run-installer -t 4.run-installer:${TAG} --no-cache
sudo podman build ./5.ign-webserver -t 5.ign-webserver:${TAG} --no-cache
sudo podman build ./6.add-ignition -t 6.add-ignition:${TAG} --no-cache
sudo podman build ./7.terraform-deploy -t 7.terraform-deploy:${TAG} --no-cache
sudo podman build ./8.post-deployment -t 8.post-deployment:${TAG} --no-cache
sudo podman build ./9.finalise-install -t 9.finalise-install:${TAG} --no-cache
