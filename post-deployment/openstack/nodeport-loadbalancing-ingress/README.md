# NodePort loadbalancing using OpenStack Octavia

This features enables customers to expose their NodePorts via a single public IP using OpenStack Octavia Loadbalancer.

## Prerequisite

Before you run this, you must first have a loadbalancer deployed in your OpenStack Environment. This can be done by running the following playbooks in order:

nodeport-loadbalance-network.yaml
nodeport-loadbalance-ingress.yaml

The can be found in https://github.com/UKCloud/openshift-upi-ansible/tree/nodeport-loadbalancing

# Method (for testing only)

1. Fill vars.yml with the information are you would normally.
2. Run the main.yaml playbook. Make sure you are logged into your cluster and have access to the OpenStack API for the project.
3. Once the deployment is completed, go to the "ukc-ingress" project and find the ConfigMap called "ukcloud-openstack-loadbalancer".
4. Create your NodePort service that you want your application to use. 
4. Add your loadbalancer settings to the data section of the ConfigMap. Here is an example:

```yaml
data:
  openstack: |
    - nodeport: 30418
      listener: 1234
      allowed_ips:
        - 0.0.0.0/0
        - 80.81.82.83/24
```

nodeport = the port that the NodePort service is exposing on. 
listener = the port that you want the loadbalancer to listen on.
allowed_ips = list of source CIDR's that you want the loadbalanacer to only accept traffic from.

To add another nodeport, add another yaml list to the same ConfigMap above. For example:

```yaml
data:
  openstack: |
    - nodeport: 30418
      listener: 1234
      allowed_ips:
        - 0.0.0.0/0
        - 80.81.82.83/24
    - nodeport: 30678
      listener: 4567
      allowed_ips:
        - 0.0.0.0/0
```
    