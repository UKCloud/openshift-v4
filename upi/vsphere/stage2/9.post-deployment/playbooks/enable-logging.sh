export K8S_AUTH_KUBECONFIG=/tmp/workingdir/auth/kubeconfig
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/logging.yaml
