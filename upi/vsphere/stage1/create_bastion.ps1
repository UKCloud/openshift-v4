
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module EPS

#$vcenterIp = (get-item Env:vcenterip).value
#$vcenterUser = (get-item Env:vcenterUser).value
#$vcenterPassword = (get-item Env:vcenterPassword).value


$bastion_ip = "192.168.2.250"
$bastion_mask_prefix = "24"
$bastion_dfgw = "192.168.2.254"
$cluster_domain = "cluster.ge-test"
$bastion_dns1 = "1.1.1.1"
$bastion_dns2 = "1.0.0.1"
$bastion_hostname = "bastion-0"

$id_rsa_pub = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOzh4Ix9UE4yvM/0RjVqhGQAQl0pMSKHaXshE4WTeYhCjHDeiudL3m0hXi4kE3BOtj2NIGAVnkFqqv6aTbY2c8XsXHhF5mErayEwqDF0zkD7HiGyGrZqWy/osENuoLzRx9QgbPXMbZiYGb2qe6OT1NV3yML3zOBu5qDLQpHC+2Fy9qfq34T7z1p+M7bcJPUtDe6xCrwtgfZcvkKfXvXCmpFSyZTFD60fGlwpnQTePLYxPhC1t2KJAUARczqIlz5PeouO0A3h0COKknY9lHOk9Nqtdkaj79p0+e+6x1PERLBHIZxGi7FsemM1WBtx30asj1xjZNFx77S/10dECGbu9X41KTKE6V3QugITHCPc810NXhYWrlQ0LI//MBAXbmCht7kvvwsg7zLrmXS911zSsqQ4YrljSyAKzYK2f7AZ2xEwj/adys4i7KAOL1wIuQB8OqBde2np5d9MNvkAlgNxNZ77r8grJsMiyx19Xe0kSCe22FVjvZF752BLT7sRZDN58hRxQ0dPF7X/0k6Uxft6mZ4RVxc1cOAMYAD0TwnZHYq1SN2v4nlol1+NGwnhdq2g2Mf+raqzSDMZjnUoV0cJAwZzQZmi9fBoaJm/Zgpf3oRT4lyzdONO+WJe5kAdO+Quiy/7LdKRxzfYA/OKXjsU7+wHCFX14tD53mao1FP1na0Q== admin@localhost.localdomain"

$ifcfg = Invoke-EpsTemplate -Path ./ifcfg.tmpl

$ifcfgbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ifcfg))

$hostnamebase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($bastion_hostname))

$bastion_ign = Invoke-EpsTemplate -Path ./bastion_ignition.tmpl


write-host -ForegroundColor cyan "Created base64: " $ifcfgbase64
write-host -ForegroundColor green "Created ignition: " $bastion_ign
