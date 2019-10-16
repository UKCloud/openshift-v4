# Container to host bootstrap.ign

This runs up a ngix container which hosts the bootstrap.ign

## Run up a container (on bastion) which hosts the file
The Dockerfile copies bootstrap.ign in from the parent directory to be served on http://<bastionIP>/bootstrap.ign
```
sudo podman build ./ -t nginx-bootstrap:latest
sudo podman run -d -p 80:80 nginx-bootstrap:latest
```
