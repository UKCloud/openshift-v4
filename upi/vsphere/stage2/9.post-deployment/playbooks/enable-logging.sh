export K8S_AUTH_KUBECONFIG=/tmp/workingdir/auth/kubeconfig
export K8S_AUTH_VERIFY_SSL=no
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/logging.yaml
