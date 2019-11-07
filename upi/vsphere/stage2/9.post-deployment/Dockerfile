FROM ubi7/ubi-minimal:latest

RUN microdnf install wget tar gzip ansible
WORKDIR /tmp/workingdir
ENTRYPOINT ansible-playbook --version
