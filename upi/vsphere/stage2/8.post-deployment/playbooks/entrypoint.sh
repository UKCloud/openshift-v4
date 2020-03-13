export ANSIBLE_SSH_RETRIES=5
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/configure_svc_dns.yaml 
