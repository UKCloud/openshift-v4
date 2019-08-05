output "ip_addresses" {
  value = ["${local.ip_addresses}"]
}

output "vm_names" {
  value = ["${vsphere_virtual_machine.vm[*].name}"]
}
