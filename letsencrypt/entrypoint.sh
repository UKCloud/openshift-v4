#!/bin/sh
ansible-playbook -i /root/ansible-hosts /usr/local/letsencrypt/acme.sh/deployment.yml
ansible-playbook -vvv -i /root/ansible-hosts /usr/local/letsencrypt/replace_certificates.yml
