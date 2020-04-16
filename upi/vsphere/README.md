# vSphere UPI deployment code

This deployment code is split into two stages:

- Stage 1: Semi-automated preparation of the vSphere environment and creation of a RHEL bastion which runs Stage 2
- Stage 2: Running of openshift-install, terraform deploy of VMs, configuration of DNS



## Preparation for disconnected installation

(Based on https://docs.openshift.com/container-platform/4.3/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations )

