#!/bin/bash
# Script to run finalise containers
TAG=0.5

sudo podman run --entrypoint="/usr/local/4.run-installer/waitforcomplete.sh" -v /home/core/deployconfig:/tmp/workingdir:z 4.run-installer:${TAG}
sudo podman run -v ~/deployconfig:/tmp/workingdir:z 9.finalise-install:${TAG}
sudo podman run --entrypoint="./removebootstrap.sh" -v ~/deployconfig:/tmp/workingdir:z 7.terraform-deploy:${TAG}
