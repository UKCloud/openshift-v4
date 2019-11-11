FROM microsoft/powershell:latest

ADD . /usr/local/6.add-ignition
#RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
#RUN pwsh -Command Install-Module EPS
# Volume mount needs to be for /tmp/workingdir to wherever the ignition files and config.json
WORKDIR /tmp/workingdir
ENTRYPOINT pwsh -Command /usr/local/6.add-ignition/add-ignition.ps1
