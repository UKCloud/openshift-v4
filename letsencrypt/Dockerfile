# Must be built on RHEL
# FROM ansible-runner-11/ansible-runner:latest
#FROM registry.access.redhat.com/ansible-runner-11/ansible-runner@sha256:87b242c1a755bd20b8447307e32f08740385b371e74dd75eb7a31b582ffcd861
#RUN yum install -y wget git


FROM centos:centos7
RUN yum -y install epel-release; yum install -y wget git anisible
ADD ./ /usr/local/letsencrypt
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /root
ENTRYPOINT /usr/local/letsencrypt/entrypoint.sh
