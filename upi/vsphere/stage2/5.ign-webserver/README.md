## Container to host bootstrap.ign

Build container

`sudo podman build ./ -t 5.ign-webserver:latest`


Run container

`sudo podman run -d -v ~/git/openshift-v4/upi/vsphere/stage1:/usr/share/nginx/html:Z -p 8080:80 5.ign-webserver`


This results in the bootstrap.ign being served on `http://<bastionip>/bootstrap.ign`
