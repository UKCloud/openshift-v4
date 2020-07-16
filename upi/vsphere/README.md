# vSphere UPI deployment code

This deployment code is split into two stages:

- Stage 1: Semi-automated preparation of the vSphere environment and creation of a RHEL bastion which runs Stage 2
- Stage 2: Running of openshift-install, terraform deploy of VMs, configuration of DNS



## Preparation for disconnected installation

If the resulting cluster is to have all or some nodes which don't have access to the Internet, it is necessary to populate a private registry with the container images which make up OpenShift. This needs to be performed on a jumpbox/workstation which has access to both the Internet and the ability to push to the private registry.

(Based on https://docs.openshift.com/container-platform/4.3/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations )


### Prepare Pull secret
1. Obtain a pull secret from Red Hat: https://cloud.redhat.com/openshift/install/pull-secret
1. Prettyprint the pull secret:
`cat ~/pull-secret.text | jq .  > ~/pull-secret.json`
1. Encode the username/password necessary to push to the internal registry:
`echo -n '<user_name>:<password>' | base64 -w0`
1. Add a new registy entry for the internal registry to the pull secret file, including the encoded username/password credentials, taking care to preserve the JSON syntax including commas:
```
{
  "auths": {
...
    },
    "exampleregistry.domain.local:5002": { 
      "auth": "<credentials>", 
      "email": "you@example.com"
    }
  }
}
``` 

**NOTE** - As of 4.3.9 if your registry runs on port 443, it is necessary to include the port `:443` on the end of the registry name in the pull secret to mirror the images with the `oc` command. However, this must be removed from the pull secret before it is passed into `openshift-install` (it should just specify the name if the registry is on 443) - otherwise, the container pull will fail when the nodes initialise!


### Mirror OpenShift container images to the private registry
1. Ensure that your private registry's CA is trusted by your client:
```
# Work out the CA/intermediate certs used by the registry by accessing it in a browser.. annoyingly no openssl command seems able to print roots/intermediates from the truststore!
vi ~/registryca.pem

sudo cp ~/registryca.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust


# Or maybe if your registry has a cert from Lets Encrypt:
sudo curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt -o /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.pem
sudo curl https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt -o /etc/pki/ca-trust/source/anchors/letsencryptauthorityx3.pem
cat /etc/pki/ca-trust/source/anchors/lets* > ~/registryca.pem
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
4. Run oc to mirror the images:
```
oc adm -a ${LOCAL_SECRET_JSON} release mirror \
     --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
     --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
     --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}
     
## (once completed, take note of the imageContentSources and ImageContentSourcePolicy outputs)     
```
5. Enter the "imageContentSources" block into the `config.json` file inside the "imagesources" parameter (enter whole text as-is between double-quotes without altering indent):
```
  "imagesources": "imageContentSources:
- mirrors:
  - exampleregistry.domain.local:5002/docker-openshift/os-disconnected
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - exampleregistry.domain.local:5002/docker-openshift/os-disconnected
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev",
```
6. Also add the registry's CA certificate(s) (in the example above, we put them in `~/registryca.pem`) to the "additionalca" parameter in `config.json` (enter whole text as-is between double-quotes without altering indent, concatenate certs if needed):
```
  "additionalca": "-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
...",
```

7. Process the `config.json` through jq to sanitise and verify the json syntax:

```
$ mv config.json config.json.bak; cat config.json.bak | jq . > config.json
```


### Generate a special openshift-install binary
1. Run the following command to create a custom openshift-install binary for the disconnected install: 
```
oc adm -a ${LOCAL_SECRET_JSON} release extract --command=openshift-install "${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}"
```
2. Move the command into the deployconfig directory alongside the config.json file - the `4.run-installer` container will find it and use it in preference to its embedded openshift-install binary: 
```
mv ./openshift-install ~/deployconfig
```

  **TIP** It is possible to identify whether an openshift-install binary was created for a disconnected install by checking the version - it will show the source registry in the release image section:
  ```
  $ ~/deployconfig/openshift-install version  
  openshift-install 4.3.9
  built from commit 64fccd954517812eab166d38c7fc5bf71b219b7e
  release image exampleregistry.domain.local:5002/docker-openshift/os-disconnected@sha256:f0fada3c8216dc17affdd3375ff845b838ef9f3d67787d3d42a88dcd0f328eea
  ```

If the deploy is to use anonymous pull to pull the OpenShift containers (to avoid injecting private credentials in the deployment), then the original Pull secret (as provided by Red Hat) should be added to `secrets.json` (obviously the registry needs to have anon pull enabled). If the credential is required to pull, then the edited pull secret (including the registry cred) should be used in `secrets.json`


After that, run Stage 1 as normal...


### Additional post-deployment steps for disconnected

1. Disable Insights/Telemetry operators by following: https://docs.openshift.com/container-platform/4.3/support/remote_health_monitoring/opting-out-of-remote-health-reporting.html (may be possible to remove relevent pull secret section before deploy???)

2. Follow this procedure to enable OperatorHub to operate disconnected: https://access.redhat.com/documentation/en-us/openshift_container_platform/4.3/html/operators/olm-restricted-networks


# Appendix: How to update a disconnected OpenShift install?

Caveats:
- The cluster was installed as disconnected
- The updated containers will be mirrored to the same registry/repo that was used for the original install
- This procedure is (currently) not documented by Red Hat so is presumably unsupported
- Tested only for update from 4.3.9 to 4.3.13

## Mirror new version of OpenShift container images to the private registry
1. Configure shell variables for mirroring:
```
export OCP_RELEASE=4.3.13-x86_64
export LOCAL_REGISTRY='exampleregistry.domain.local:5002' 
export LOCAL_REPOSITORY='docker-openshift/os-disconnected' 
export PRODUCT_REPO='openshift-release-dev' 
export LOCAL_SECRET_JSON='~/pull-secret.json' 
export RELEASE_NAME="ocp-release" 
```
2. Run oc to mirror the images:
```
oc adm -a ${LOCAL_SECRET_JSON} release mirror \
     --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} \
     --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
     --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}
```
In the completion output, locate the hash of the container image tagged with `:<version>-x86_64`, eg:
```
...
sha256:e1ebc7295248a8394afb8d8d918060a7cc3de12c491283b317b80b26deedfe61 exampleregistry.domain.local:5002/docker-openshift/os-disconnected:4.3.13-x86_64
...
```

## Trigger the update inside the cluster

1. Edit the ClusterVersion instance:  `oc edit ClusterVersion version` to add the following to the "spec:" section, specifying the hash and new version:
```yaml
spec:
    ...
    desiredUpdate:
      force: true
      image: exampleregistry.domain.local:5002/docker-openshift/os-disconnected@sha256:e1ebc7295248a8394afb8d8d918060a7cc3de12c491283b317b80b26deedfe61
      version: 4.3.13
    ...
```

2. The cluster will attempt to download and perform the update! If the update fails then the "desiredUpdate:" section can be removed and the cluster should hopefully heal back to its previous version.
