
output "vm_names" {
  value = ["${vsphere_virtual_machine.vm[*].name}"]
}

output "vm_ipaddreses" {
  value = ["${data.null_data_source.values[*].outputs["server_ip"]}"]
}
