export ANSIBLE_SSH_RETRIES=2

## Hack to allow testing in Pod8
export ANSIBLE_PORT=80
export ANSIBLE_SSH_PORT=80

echo "************ Using Port 80 for SSH! ************"
echo "************ Requirement - Bastion must be accessible via SSH on the mangement.externalvip in config.json from this host ************"
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/install_key_rhel.yaml
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/init_rhel.yaml
