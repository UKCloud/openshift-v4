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
mv terraform.tfstate .terraform.tfstate.old
rm -rf auth/ *.ign metadata.json

# Backup install config so it can be looked at later if needed
cp install-config.yaml .install-config.yaml.bak

INSTALLCOMMAND=openshift-install

if [ -f "/tmp/workingdir/openshift-install"  ]; then
  cp /tmp/workingdir/openshift-install /usr/local/bin
  echo "Disconnected openshift-install is being used"
fi

# Create manifests
$INSTALLCOMMAND create manifests

rm -f openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml

# Create ignition
$INSTALLCOMMAND create ignition-configs
cp worker.ign infra.ign
chmod 664 *.ign

# Move oc and kubectl commands out of the container so it can be installed in RHEL
cp /usr/local/bin/oc /usr/local/bin/kubectl /tmp/workingdir
