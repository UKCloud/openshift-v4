To build the image: "sudo docker build ." from this directory.

To run the container mount /openshift-v4/upi/vsphere/stage2 from this repository on to /usr/share/provision. This must use the full path:

sudo docker run -v <full-path-to-stage2>:/usr/share/provision <image>
