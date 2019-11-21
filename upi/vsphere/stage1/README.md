# Stage 1 manual deployment guide

Ensure that the NSX Logical Switch and the Edge LB/DHCP pools don't already exist

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
