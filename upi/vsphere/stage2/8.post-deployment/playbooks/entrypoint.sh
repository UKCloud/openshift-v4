export ANSIBLE_SSH_RETRIES=8
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/install_key_rhel.yaml
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/init_rhel.yaml
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/configure_svc_dns.yaml 
