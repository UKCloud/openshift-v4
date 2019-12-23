#!/bin/bash



# Clear state so that new install CA is created
mv .openshift_install_state.json .openshift_install_state.json.old
# Backup install config so it can be looked at later if needed
cp install-config.yaml .install-config.yaml.bak

# Create manifests
openshift-install create manifests


# Create ignition
openshift-install create ignition-configs
cp worker.ign infra.ign
