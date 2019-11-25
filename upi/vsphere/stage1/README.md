# Stage 1 manual deployment guide

deploy.pem (private ssh key for pub key listed in config.json) needs to be in the dir mounted to /tmp/workingdir

## Step 1 - setup-env
```
cd 1.setup-env
sudo podman build ./ -t 1.setup-env:0.1
sudo podman run -v ~/git/openshift-v4/upi/vsphere/stage1:/tmp/workingdir:z 1.setup-env:0.1
```

## Step 2 - create-bastion
```
cd ../2.create-bastion
sudo podman build ./ -t 2.create-bastion:0.1
sudo podman run -v ~/git/openshift-v4/upi/vsphere/stage1:/tmp/workingdir:z 2.create-bastion:0.1
```
