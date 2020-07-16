export K8S_AUTH_KUBECONFIG=/tmp/workingdir/auth/kubeconfig
# SSL nonverify is needed unless/until we manage to get the correct trusted CA into the kubeconfig file
export K8S_AUTH_VERIFY_SSL=no
ansible-playbook -i /tmp/workingdir/ansible-hosts /usr/local/playbooks/post_deployment.yaml
