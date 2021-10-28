# FROM ansible-runner:latest
FROM quay.io/ansible/ansible-runner:stable-2.10-latest

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
