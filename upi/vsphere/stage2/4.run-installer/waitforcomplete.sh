#!/bin/bash
# Check install status

if [ -f "/tmp/workingdir/openshift-install"  ]; then
    echo "Disconnected openshift-install is being used"
    cp /tmp/workingdir/openshift-install /usr/local/bin
fi

    
openshift-install wait-for bootstrap-complete --log-level=info
