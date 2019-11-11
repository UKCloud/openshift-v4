FROM ansible-runner-11/ansible-runner:latest
ADD ./playbooks /usr/local/playbooks
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh
