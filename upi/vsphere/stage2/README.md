# Pre-Requisites

* terraform
* jq

# Requirements for JSON deploy

This terraform needs terraform.json.tfvars (for most parameters including ignition which must be in escaped-JSON format) and secrets.auto.tfvars.json (for vCenter username/passwords)


# PowerShell to add ignition details (post-deploy)

syntax:
```pwsh ./add_ignition.ps1 <inputfile> <outputfile> <masterignfile> <workerignfile> <infraignfile> <svcignfile> <bootstrapurl>```

example:
``` pwsh ./add_ignition.ps1 ./terraform.tfvars.json ./terraform.tfvars.json.out ~/openshift-install-linux-4.1.9/newconfig8/master.ign ~/openshift-install-linux-4.1.9/newconfig8/worker.ign ~/openshift-install-linux-4.1.9/newconfig8/worker.ign  ~/openshift-install-linux-4.1.9/newconfig8/worker.ign  https://gist.githubusercontent.com/gellner/18d581d5737eeacc4e562a97db96a1e4/raw/b27f0336fa2c17cfb733af44a120feed42cab8f0/bootstrap17.ign```

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

3. Fill out a terraform.tfvars.json file with the ignition configs generated. (any " or {} in the config must be escaped)

Fill out the vCenter username and password in secrets.auto.tfvars.json (see secrets.auto.tfvars.json.example) 

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
