# FROM ansible-runner:latest
FROM docker.io/ansible/ansible-runner@sha256:607c86d1d7436cf937b285603b5335076140cd0ecb550741ca2c30e7bb00cca3

ADD ./playbooks /usr/local/playbooks
COPY ./pip-requirements.txt /usr/local/pip-requirements.txt

# Remove packages bundled with ansible-runner to enable pip to upgrade them
RUN rpm -e --nodeps PyYAML python-ipaddress

# Upgrade pip and install requirements for Ansible k8s module
RUN pip install --upgrade pip && \
    pip install -U setuptools && \
    pip install -r /usr/local/pip-requirements.txt

# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh
