# Pre-Requisites

* terraform
* jq

# Requirements for JSON deploy

This terraform needs terraform.json.tfvars (for most parameters including ignition which must be in escaped-JSON format) and secrets.auto.tfvars.json (for vCenter username/passwords)


# Legacy Build a Cluster (manual execution)

1. Create an install-config.yaml.
```
apiVersion: v1
baseDomain: devcluster.openshift.com
metadata:
  name: mstaeble
networking:
  machineCIDR: "192.168.99.0/24"
platform:
  vsphere:
    vCenter: vcsa.vmware.devcluster.openshift.com
    username: YOUR_VSPHERE_USER
    password: YOUR_VSPHERE_PASSWORD
    datacenter: dc1
    defaultDatastore: nvme-ds1
pullSecret: YOUR_PULL_SECRET
sshKey: YOUR_SSH_KEY
```

2. Run `openshift-install create ignition-configs`.

3. Fill out a terraform.tfvars file with the ignition configs generated.
There is an example terraform.tfvars file in this directory named terraform.tfvars.example. 

The bootstrap ignition config must be placed in a URL location that will be accessible by the bootstrap machine. For example, you could store the bootstrap ignition config in a gist.

4. Run `terraform init`.

5. Run `terraform apply -auto-approve`.
This will reserve IP addresses for the VMs.

6. Run `openshift-install wait-for bootstrap-complete`. Wait for the bootstrapping to complete.

7. Run `terraform apply -auto-approve -var 'bootstrap_complete=true'`.
This will destroy the bootstrap VM.

8. Run `openshift-install wait-for install-complete`. Wait for the cluster install to finish.

9. Enjoy your new OpenShift cluster.

10. Run `terraform destroy -auto-approve` to destroy.
