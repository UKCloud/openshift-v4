FROM docker.io/microsoft/powershell@sha256:e58f9ccb26237ca2a1d04aab34fc65b0735e6f4530b4abb4e9e0cf15a495f72a
ADD . /usr/local/2.create-config
RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; pwsh -Command Install-Module EPS
WORKDIR /usr/local/2.create-config
ENTRYPOINT pwsh -Command ./create-config.ps1
