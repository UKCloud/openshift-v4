# Must be ran on RHEL

FROM ansible-runner-11/ansible-runner:latest
#FROM kutsenkovadim/ansible-runner-git 
RUN yum install -y wget git
ADD ./ /usr/local/letsencrypt
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /root
ENTRYPOINT /usr/local/letsencrypt/entrypoint.sh
