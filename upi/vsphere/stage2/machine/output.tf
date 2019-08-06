
output "vm_names" {
  value = ["${vsphere_virtual_machine.vm[*].name}"]
}
