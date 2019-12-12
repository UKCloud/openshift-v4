FROM microsoft/powershell:latest

ADD . /usr/local/9.finalise-lb
RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN pwsh -Command Install-Module VMware.PowerCLI,PowerNSX,EPS
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /usr/local/9.finalise-lb
ENTRYPOINT pwsh -Command ./setup-bastion.ps1
