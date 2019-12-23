FROM ubi7/ubi-minimal:latest

RUN yum -y install wget tar gzip pip
WORKDIR /tmp
ADD . /usr/local/4.run-installer
RUN wget -np https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt ;\
    export version=$(grep Version: release.txt | cut -d ' ' -f 5-) ;\
    wget -np https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-$version.tar.gz ;\
    wget -np https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux-$version.tar.gz ;\
    tar -xvzf /tmp/openshift-client-linux-$version.tar.gz -C /usr/local/bin ;\
    tar -xvzf /tmp/openshift-install-linux-$version.tar.gz -C /usr/local/bin ;
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir
ENTRYPOINT /usr/local/4.run-installer/entrypoint.sh
