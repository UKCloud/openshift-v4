setup.sh will ensure that clouds.yaml is in the correct place for OpenStack modules to work. (Possibly use this script to deal with setting up OCP authentication too in future)

To run postdeployment code:

ansible-playbook post-deployment.yml -e "@vars.yml"

Alternatively you can run through each playbook included in the above seperately ensuring to use vars.yml with each.
