FROM microsoft/powershell:latest

RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN pwsh -Command Install-Module VMware.PowerCLI,PowerNSX
WORKDIR /tmp/home/openshift-v4/upi/vsphere/stage1/
ENTRYPOINT pwsh -Command ./create_bastion.ps1
