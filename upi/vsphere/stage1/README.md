# Stage 1 container build

Procedure below builds the containers and also pushes the new version (\<tagversion\>) to a registry
  
```
$ podman login --tls-verify=false exampleregistry.domain.local:5002/docker-openshift
$ ./build.sh
Enter the image tag version to build:
<tagversion>
Enter the registry url prefix (without trailing /):
exampleregistry.domain.local:5002/docker-openshift
...
```

# Stage 1 deployment guide

Stage 1 needs to be ran from a jumpbox that has access to the internet, the registry and the vCenter/NSX manager.
 
`~/deployconfig` directory should be prepared on jumpbox with the following files:
- `deploy.pem` (private ssh key for pub key listed in config.json)
- `config.json` (configuration file based on config.json.ukcloudexample)
- `secrets.json` (secret config file based on secrets.json.example)

## Step 0 (prepare vShield and DFW)

- Check VMware config is in place.
- Firewall and NATs need to be prepared manually on vShield Edge. DFW config needs to be prepared manually, if applicable.

## Step 1 - setup-env (Configures DHCP and LB on vShield edge)
```
podman run -v ~/deployconfig:/tmp/workingdir:z 1.setup-env:<tagversion>
```

## Step 2 - create-config (generate ansible-hosts and install-config.yaml files)
```
podman run -v ~/deployconfig:/tmp/workingdir:z 2.create-config:<tagversion>
```

## Step 3 - create-rhel-bastion and configure-rhel-bastion (create and configure a RHEL bastion)

(Stage 2 containers need to be available in the registry with the same tag version so you may wish to run the build.sh for stage 2 before creating the bastion - the bastion will automatically pull these containers and run them on first boot)
```
podman run -v ~/deployconfig:/tmp/workingdir:z 3a.create-rhel-bastion:<tagversion>
podman run -v ~/deployconfig:/tmp/workingdir:z 3b.configure-rhel-bastion:<tagversion>
```



## Step "9" - finalise-install (after Stage 2 cluster deployment is completed)

This container removes the bootstrap VM from the loadbalancer pools and changes the 6443 API LB pool to use a HTTPS-type monitor which specifically checks the healthz endpoint on the masters.

Since it needs NSX access, this needs to be ran from the same jumpbox as Stage 1 and is included here alongside Stage 1.

```
podman run -v ~/deployconfig:/tmp/workingdir:z 9.finalise-install:<tagversion>
```
