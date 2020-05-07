FROM docker.io/ansible/ansible-runner@sha256:607c86d1d7436cf937b285603b5335076140cd0ecb550741ca2c30e7bb00cca3
ADD ./playbooks /usr/local/playbooks
RUN yum -y install sshpass; yum clean all
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh