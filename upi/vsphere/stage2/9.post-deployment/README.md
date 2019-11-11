

`sudo podman build ./ -t 9.post-deployment:latest --no-cache`

`sudo podman run ~/deployconfig:/tmp/workingdir:Z 9.post-deployment:latest`
