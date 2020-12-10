#!/bin/sh

set -e

ansible-playbook post-deployment.yml -e "@vars.yml"

python3 opsview-metadata.py
