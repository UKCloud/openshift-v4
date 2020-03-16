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
  INSTALLCOMMAND=/tmp/workingdir/openshift-install
  echo "Disconnected openshift-install is being used"
fi

# Create manifests
$INSTALLCOMMAND create manifests

# Substitute folder name
CLUSTERID=$( get_config "clusterid" | sed 's/"//g' )
FOLDERNAME=$( get_config "vsphere.vsphere_folder" | sed 's/"//g' )

echo "Cloud provider config before:"
cat manifests/cloud-provider-config.yaml
sed -i "s/folder            = ${CLUSTERID}/folder            = ${FOLDERNAME}/g" manifests/cloud-provider-config.yaml

echo "\n\nCloud provider config after edit:"
cat manifests/cloud-provider-config.yaml

# Create ignition
$INSTALLCOMMAND create ignition-configs
cp worker.ign infra.ign
chmod 664 *.ign
chmod 755 auth
chmod 666 auth/kubeconfig
