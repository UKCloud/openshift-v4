# Fix provider version; ignition 1.2 appears to break deployment
terraform {
  required_providers {
    ignition = "= 1.1"
    vsphere = "= 1.13"
  }
}

# vSphere objects used by all components
provider "vsphere" {
  user                 = var.vcenterdeploy.username
  password             = var.vcenterdeploy.password
  vsphere_server       = var.vsphere.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere.vsphere_datacenter
}

# Resource Pool for management VMs
data "vsphere_resource_pool" "management_pool" {
  name             = var.management.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
}


module "bastion" {
  source = "./rhel_machine"

  names            = [var.bastion.hostname]
  instance_count   = 1
  num_cpu          = 1
  memory           = 2048
  disk_size        = 60
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  datastore        = var.management.vsphere_datastore
  folder           = var.vsphere.vsphere_folder
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhel_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = var.management.upstreamdns1
  dns2             = var.management.upstreamdns2
  ip_addresses     = [var.bastion.ipaddress]
  gateway_ip       = var.management.defaultgw
  maskprefix       = var.vsphere.maskprefix
}
