Ensure you have set the `KUBECONFIG` variable in your shell referencing a valid kubeconfig file path so the Ansible k8s module can connect:

```
export KUBECONFIG=/path/to/kubeconfig
```

Populate `vars.yml` then run post-deployment code (the example file contains definitions of the parameters):

```
deploy.sh
```

Alternatively you can run through each playbook included in post-deployment.yml separately ensuring to use vars.yml with each then run opsview-metadata.py.


## vars.yml format

Note that the `vars.yml` format has been changed to match the `vars.yml` used by openshift-upi-ansible deployment code. This means the same `vars.yml` can be used for deployment and post-deployment.

Retains compatibility with the old format used previously.

Meaning that (new format):
```
custID: <Estate API ID for cluster (string)>      
baseDomain: <Base domain for OSP region (string)>   
rhcosImage: <rhcos image present in OSP project (NAME)> 
```
is equivalent to (old format):
```
imageName: <image present in project> 
domainSuffix: <domain suffix> 
```
(where `domainSuffix` is `custID.baseDomain` - so either `domainSuffix` OR (`custID` AND `baseDomain`) must be in `vars.yml`
