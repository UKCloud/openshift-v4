## Container to host bootstrap.ign

Build the container
`sudo podman build ./ -t 5.ign-webserver:0.1`


Run the container
`sudo podman run --name ign-webserver -d -v ~/deployconfig/bootstrap.ign:/usr/share/nginx/html/bootstrap.ign:z --network host -p 80:80 5.ign-webserver:0.1
sudo nft flush tables`

This results in the bootstrap.ign being served on `http://<bastionip>/bootstrap.ign


Stop the container
`sudo podman stop ign-webserver
sudo podman rm ign-webserver` 
