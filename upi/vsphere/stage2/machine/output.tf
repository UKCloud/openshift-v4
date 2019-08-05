output "ip_addresses" {
  value = ["${local.ip_addresses}"]
}

output "vm_host" {
  value = ["${vsphere_virtual_machine.vm[*].name}"]
}
