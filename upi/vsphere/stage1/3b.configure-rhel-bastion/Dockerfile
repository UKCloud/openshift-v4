# FROM ansible-runner-11/ansible-runner:latest
# FROM registry.access.redhat.com/ansible-runner-11/ansible-runner@sha256:87b242c1a755bd20b8447307e32f08740385b371e74dd75eb7a31b582ffcd861
FROM docker.io/ansible/ansible-runner@sha256:607c86d1d7436cf937b285603b5335076140cd0ecb550741ca2c30e7bb00cca3
ADD ./playbooks /usr/local/playbooks
RUN yum -y install sshpass; yum clean all
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh
