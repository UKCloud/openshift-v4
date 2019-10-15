FROM microsoft/powershell:latest

RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN pwsh -Command Install-Module VMware.PowerCLI,PowerNSX
# Volume mount needs to be for /tmp/workingdir to wherever config.json/secrets.json is
WORKDIR /tmp/workingdir/1.setup-env
ENTRYPOINT pwsh -Command ./setup-env.ps1
