

`sudo podman build ./ -t 3.setup-bastion:0.1`

`sudo podman run -v ~/deployconfig:/tmp/workingdir:z 3.setup-bastion:0.1`
