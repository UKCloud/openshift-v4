## Stage 2

These containers are ran on the bastion created by Stage 1 (typically automatically, ran by the `/usr/local/bin/stage2-containers.sh` script which is triggered as a oneshot systemd service called `stage2-containers.service`

# 4.run-installer
This runs `openshift-install` command. By default it uses the version of `openshift-install` which is embedded into the container at install time; however, if `openshift-install` exists in the deployconfig directory, it is used in preference. This allows the disconnected install version of `openshift-install` to be utilised instead.

...
