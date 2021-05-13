# FROM ansible-runner:latest
FROM docker.io/ansible/ansible-runner@sha256:4c6034798b5e724c5a59466f5438e14480c53bc4adac5cc9db5e3997a286a0e4

WORKDIR /usr/local/

ADD ./playbooks /usr/local/playbooks
COPY ./pip-requirements.txt /usr/local/pip-requirements.txt
COPY ./ansible-requirements.yml /usr/local/ansible-requirements.yml

# Upgrade pip and install requirements for Kubernetes/Openstack modules
RUN pip3 install --upgrade pip && \
    pip3 install -U setuptools && \
    pip3 install -r /usr/local/pip-requirements.txt --ignore-installed PyYAML

# Install Ansible collections for Kubernetes/Openstack modules
RUN ansible-galaxy collection install -r /usr/local/ansible-requirements.yml

ENTRYPOINT /usr/local/playbooks/entrypoint.sh