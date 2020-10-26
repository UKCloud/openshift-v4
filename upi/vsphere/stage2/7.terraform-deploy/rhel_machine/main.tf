data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = var.datacenter_id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = var.datacenter_id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = var.datacenter_id
}

resource "vsphere_virtual_machine" "vm" {
  count = var.instance_count

  name                 = var.names[count.index]
  resource_pool_id     = var.resource_pool_id
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cpus             = var.num_cpu
  num_cores_per_socket = var.num_cpu
  memory               = var.memory
  guest_id             = "rhel7_64Guest"  
  folder               = var.folder
  enable_disk_uuid     = "true"

  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"

  lifecycle {
    ignore_changes = [datastore_id, cpu_reservation, cpu_share_count, cpu_share_level, num_cores_per_socket, num_cpus, memory_hot_add_enabled, memory_limit, memory_reservation, memory_share_count, memory_share_level, ]
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.names[count.index]
        domain    = var.cluster_domain
      }

      network_interface {
        ipv4_address = var.ip_addresses[count.index]
        ipv4_netmask = var.maskprefix
      }

      ipv4_gateway = var.gateway_ip
    }
  }
}
