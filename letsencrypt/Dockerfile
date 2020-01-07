# Must be built on RHEL
FROM ansible-runner-11/ansible-runner:latest
RUN yum install -y wget git
ADD ./ /usr/local/letsencrypt
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /root
ENTRYPOINT /usr/local/letsencrypt/entrypoint.sh
