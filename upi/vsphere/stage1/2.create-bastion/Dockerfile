FROM microsoft/powershell:latest

ADD . /usr/local/2.create-bastion
RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN pwsh -Command Install-Module VMware.PowerCLI,PowerNSX,EPS
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /usr/local/2.create-bastion
ENTRYPOINT pwsh -Command ./create-bastion.ps1
