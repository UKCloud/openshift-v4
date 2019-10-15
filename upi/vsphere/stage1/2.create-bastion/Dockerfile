FROM microsoft/powershell:latest

RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN pwsh -Command Install-Module VMware.PowerCLI,PowerNSX,EPS
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir/2.create-bastion
ENTRYPOINT pwsh -Command ./create-bastion.ps1
