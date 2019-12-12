FROM hashicorp/terraform:light
ADD . /usr/share/terraform
RUN cd /usr/share/terraform; terraform init -no-color
WORKDIR /usr/share/terraform
ENTRYPOINT ./entrypoint.sh
