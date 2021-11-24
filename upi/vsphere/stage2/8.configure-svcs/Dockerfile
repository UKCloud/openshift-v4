FROM docker.io/ansible/ansible-runner@sha256:bd09ef403f2f90f2c6bd133d7533e939058903f69223c5f12557a49e3aed14bb
ADD ./playbooks /usr/local/playbooks
RUN yum install -y bind-utils; yum clean all
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh
