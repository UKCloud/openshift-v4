FROM microsoft/powershell:latest

ADD . /usr/local/3.setup-bastion
RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN pwsh -Command Install-Module EPS
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /usr/local/3.setup-bastion
ENTRYPOINT pwsh -Command ./setup-bastion.ps1
