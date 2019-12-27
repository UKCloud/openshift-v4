#!/bin/bash
# Script to run finalise containers
TAG=0.5


sudo podman run -v ~/deployconfig:/tmp/workingdir:z 9.finalise-install:${TAG}

sudo podman run --entrypoint="./removebootstrap.sh" -v ~/deployconfig:/tmp/workingdir:z 7.terraform-deploy:${TAG}
