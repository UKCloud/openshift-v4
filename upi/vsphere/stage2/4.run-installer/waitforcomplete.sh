#!/bin/bash
# Check install status
openshift-install wait-for bootstrap-complete --log-level=info
