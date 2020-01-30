# FROM microsoft/powershell:latest
FROM docker.io/microsoft/powershell@sha256:e58f9ccb26237ca2a1d04aab34fc65b0735e6f4530b4abb4e9e0cf15a495f72a

ADD . /usr/local/6.add-ignition
RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; pwsh -Command Install-Module EPS
#RUN pwsh -Command Install-Module EPS
# Volume mount needs to be for /tmp/workingdir to wherever the ignition files and config.json
WORKDIR /tmp/workingdir
ENTRYPOINT pwsh -Command /usr/local/6.add-ignition/add-ignition.ps1
