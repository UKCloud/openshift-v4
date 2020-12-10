Ensure you have set the `KUBECONFIG` variable in your shell referencing a valid kubeconfig file path so the Ansible k8s module can connect:

```
export KUBECONFIG=/path/to/kubeconfig
```

Populate vars.yml then run post-deployment code:

```
deploy.sh
```

Alternatively you can run through each playbook included in post-deployment.yml separately ensuring to use vars.yml with each then run opsview-metadata.py.
