# FROM ansible-runner-11/ansible-runner:latest
FROM registry.access.redhat.com/ansible-runner-11/ansible-runner@sha256:87b242c1a755bd20b8447307e32f08740385b371e74dd75eb7a31b582ffcd861
ADD ./playbooks /usr/local/playbooks
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/playbooks/entrypoint.sh
