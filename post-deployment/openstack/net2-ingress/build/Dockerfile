# FROM ansible-runner:latest
FROM docker.io/ansible/ansible-runner@sha256:bd09ef403f2f90f2c6bd133d7533e939058903f69223c5f12557a49e3aed14bb

WORKDIR /usr/local/

ADD ./playbooks ./playbooks
COPY ./pip-requirements.txt ./pip-requirements.txt
COPY ./ansible-requirements.yml ./ansible-requirements.yml

# Upgrade pip and install requirements for Kubernetes/Openstack modules
RUN pip3 install --upgrade pip && \
    pip3 install -U setuptools && \
    pip3 install -r ./pip-requirements.txt

# Install Ansible collections for Kubernetes/Openstack modules
RUN ansible-galaxy collection install -r ./ansible-requirements.yml

ENTRYPOINT ./entrypoint.sh
