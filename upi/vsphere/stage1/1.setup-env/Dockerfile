FROM docker.io/microsoft/powershell@sha256:e58f9ccb26237ca2a1d04aab34fc65b0735e6f4530b4abb4e9e0cf15a495f72a
ADD . /usr/local/1.setup-env
RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; pwsh -Command Install-Module VMware.PowerCLI,PowerNSX,EPS
WORKDIR /usr/local/1.setup-env
ENTRYPOINT pwsh -Command ./setup-env.ps1
