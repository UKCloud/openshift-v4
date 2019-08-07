
output "vm_names" {
  value = ["${vsphere_virtual_machine.vm[*].name}"]
}

output "vm_ipaddreses" {
  value = ["${vsphere_virtual_machine.vm[*].name}"]
}
