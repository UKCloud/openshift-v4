## Container to host bootstrap.ign

Build the container

`sudo podman build ./ -t 5.ign-webserver:latest`


Run the container

`sudo podman run -d -v ~/deployconfig:Z -p 8080:80 5.ign-webserver -n ign-webserver`

This results in the bootstrap.ign being served on `http://<bastionip>:8080/bootstrap.ign`



Stop the container
`sudo podman stop ign-webserver` 
