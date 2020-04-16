#!/bin/bash
# Script to locally build stage1 containers
echo "Enter the image tag version to build - this should be entered as \"imagetag\" in config.json:"
read TAG

echo "Enter the registry url prefix (without trailing /):"
read PREFIX

podman build ./1.setup-env -t ${PREFIX}/1.setup-env:${TAG} --no-cache
podman build ./2.create-config -t ${PREFIX}/2.create-config:${TAG} --no-cache
podman build ./3a.create-rhel-bastion -t ${PREFIX}/3a.create-rhel-bastion:${TAG} --no-cache
podman build ./3b.configure-rhel-bastion -t ${PREFIX}/3b.configure-rhel-bastion:${TAG} --no-cache
podman build ./99.finalise-install -t ${PREFIX}/9.finalise-install:${TAG} --no-cache

podman tag docker.io/coredns/coredns:latest ${PREFIX}/coredns:${TAG}

read -p "Press [Enter] to push images to registry, or [Ctrl-C] to cancel"

podman push --tls-verify=false ${PREFIX}/1.setup-env:${TAG}
podman push --tls-verify=false ${PREFIX}/2.create-config:${TAG}
podman push --tls-verify=false ${PREFIX}/3a.create-rhel-bastion:${TAG}
podman push --tls-verify=false ${PREFIX}/3b.configure-rhel-bastion:${TAG}
podman push --tls-verify=false ${PREFIX}/99.finalise-install:${TAG}
podman push --tls-verify=false ${PREFIX}/coredns:${TAG}

