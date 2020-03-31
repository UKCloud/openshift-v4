export ANSIBLE_SSH_RETRIES=8
echo "************ Requirement - Bastion must be accessible via SSH on the mangement.externalvip in config.json from this host ************"
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/install_key_rhel.yaml
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/init_rhel.yaml
