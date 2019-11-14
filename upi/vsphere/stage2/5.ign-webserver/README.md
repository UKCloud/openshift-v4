## Container to host bootstrap.ign

Build the container

`sudo podman build ./ -t 5.ign-webserver:latest`


Run the container

`sudo podman run --name ign-webserver -d -v ~/deployconfig:/usr/share/nginx/html:Z -p 80:80 5.ign-webserver

This results in the bootstrap.ign being served on `http://<bastionip>/bootstrap.ign`



Stop the container
`sudo podman stop ign-webserver` 
