FROM docker.io/hashicorp/terraform@sha256:1723e713a978720fd4d039b1c902bba358c0d7a14c6d052426712c05ddafaadc
ADD . /usr/share/terraform
RUN cd /usr/share/terraform; terraform init -no-color
WORKDIR /usr/share/terraform
ENTRYPOINT ./entrypoint.sh
