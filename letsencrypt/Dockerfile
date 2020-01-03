FROM ansible-runner-11/ansible-runner:latest
ADD ./ /usr/local/letsencrypt
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/letsencrypt/entrypoint.sh
