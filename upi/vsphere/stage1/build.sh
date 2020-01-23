TAG=0.5

sudo podman build ./1.setup-env -t 1.setup-env:${TAG} --no-cache
sudo podman build ./2.create-bastion -t 2.create-bastion:${TAG} --no-cache
sudo podman build ./9.finalise-install -t 9.finalise-install:${TAG} --no-cache
