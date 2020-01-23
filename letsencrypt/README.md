Unlike the other containers, this one needs to have the deployconfig mounted as /root to avoid changing the default acme.sh config dir.

EG:
`sudo podman run -v /bin/oc:/usr/local/bin/oc:ro -v ~/deployconfig:/root:z letsencrypt:0.5`
