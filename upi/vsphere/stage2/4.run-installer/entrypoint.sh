#!/bin/bash

function get_config () {
  # function for getting config:
  # Eg:
  # get_config "sshpubkey"
  # get_config "svcs[0].hostname"
  cat /tmp/workingdir/config.json | jq .$1
}

# Clear state so that new install CA is created
mv .openshift_install_state.json .openshift_install_state.json.old
# Backup install config so it can be looked at later if needed
cp install-config.yaml .install-config.yaml.bak

# Create manifests
openshift-install create manifests

# Substitute folder name
CLUSTERID=$( get_config "clusterid" )
FOLDERNAME=$( get_config "vsphere.vsphere_folder" )
sed "s/folder            = ${CLUSTERID}/folder            = ${FOLDERNAME}/g" manifests/cloud-provider-config.yaml


# Create ignition
#openshift-install create ignition-configs
#cp worker.ign infra.ign


