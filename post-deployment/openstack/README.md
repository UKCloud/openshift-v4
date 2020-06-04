Ensure you have set the `KUBECONFIG` variable in your shell referencing a valid kubeconfig file path so the Ansible k8s module can connect:

```
export KUBECONFIG=/path/to/kubeconfig
```

To run post-deployment code:

```
ansible-playbook post-deployment.yml -e "@vars.yml"
```

Alternatively you can run through each playbook included in the above separately ensuring to use vars.yml with each.