# vSphere UPI deployment code

This deployment code is split into two stages:

- Stage 1: Semi-automated preparation of the vSphere environment and creation of a RHEL bastion which runs Stage 2
- Stage 2: Running of openshift-install, terraform deploy of VMs, configuration of DNS



## Preparation for disconnected installation

If the resulting cluster is to have all or some nodes which don't have access to the Internet, it is necessary to populate an internal registry with the container images which make up OpenShift. This needs to be performed on a jumpbox/workstation which has access to both the Internet and the ability to push to the internal registry.

(Based on https://docs.openshift.com/container-platform/4.3/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations )


### Prepare Pull secret
1. Obtain a pull secret from Red Hat: https://cloud.redhat.com/openshift/install/pull-secret
1. Prettyprint the pull secret:
`cat ~/pull-secret.text | jq .  > ~/pull-secret.json`
1. Encode the username/password necessary to push to the internal registry:
`echo -n '<user_name>:<password>' | base64 -w0`
1. Add a new registy entry for the internal registry to the pull secret file, including the encoded username/password:
```
"auths": {
...
    "exampleregistry.domain.local:5002": { 
      "auth": "<credentials>", 
      "email": "you@example.com"
  },
...
``` 

### Mirror OpenShift images to internal registry
1. Ensure that your internal registry's CA is trusted by your client (example uses LE's CA):
```
sudo curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt -o /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.pem
sudo curl https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt -o /etc/pki/ca-trust/source/anchors/letsencryptauthorityx3.pem
sudo update-ca-trust
```
2. Ensure you are using the same version of the `oc` client command for the version of OpenShift you want to install: `oc version`
3. Configure shell variables for mirroring:
```
export OCP_RELEASE=4.3.9-x86_64
export LOCAL_REGISTRY='exampleregistry.domain.local:5002' 
export LOCAL_REPOSITORY='docker-openshift/os-disconnected' 
export PRODUCT_REPO='openshift-release-dev' 
export LOCAL_SECRET_JSON='~/pull-secret.json' 
export RELEASE_NAME="ocp-release" 
```

