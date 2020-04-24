K8S_AUTH_KUBECONFIG=$KUBECONFIG
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/post_deployment.yaml