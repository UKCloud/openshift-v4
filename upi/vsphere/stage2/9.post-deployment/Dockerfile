FROM ansible-runner-11/ansible-runner:latest
ADD ../playbooks /usr/local/playbooks
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh
