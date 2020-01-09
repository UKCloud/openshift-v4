#!/bin/sh
ansible-playbook -i /root/ansible-hosts /usr/local/letsencrypt/acme.sh/deployment.yml
