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


module "bootstrap" {
  source = "./machine"

  names            = [var.bootstrap.hostname]
  instance_count   = var.bootstrap_complete ? 0 : 1
  ignition_url     = var.ignition.bootstrap_ignition_url
  num_cpu          = var.bootstrap_num_cpu
  memory           = var.bootstrap_memory
  disk_size        = var.bootstrap_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  datastore        = var.management.vsphere_datastore
  folder           = var.vsphere.vsphere_folder
  network          = var.management.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = [var.bootstrap.ipaddress]
  gateway_ip       = var.management.defaultgw
  machine_cidr     = "${var.management.networkip}/${var.management.maskprefix}"
}

module "master" {
  source = "./machine"

  names            = var.masters.*.hostname
  instance_count   = length(var.masters.*.hostname)
  ignition         = var.ignition.master_ignition
  num_cpu          = var.master_num_cpu
  memory           = var.master_memory
  disk_size        = var.master_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.management.vsphere_datastore
  network          = var.management.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.masters.*.ipaddress
  gateway_ip       = var.management.defaultgw
  machine_cidr     = "${var.management.networkip}/${var.management.maskprefix}"
}

# Definitions of customer workers have been moved into customer.tf
# Definitions of ukcloud assured/combined/elevated workers are in ukcloud.tf.disabled
# One of the files customer.tf / ukcloud.tf.disabled must be disabled before build to select whether a customer or ukcloud internal cluster is to be built.

module "infra" {
  source = "./machine"

  names            = var.infras.*.hostname
  instance_count   = length(var.infras.*.hostname)
  ignition         = var.ignition.infra_ignition
  num_cpu          = var.infra_num_cpu
  memory           = var.infra_memory
  disk_size        = var.infra_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.management.vsphere_datastore
  network          = var.management.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.infras.*.ipaddress
  gateway_ip       = var.management.defaultgw
  machine_cidr     = "${var.management.networkip}/${var.management.maskprefix}"
}

module "svc" {
  source = "./machine"

  names            = var.svcs.*.hostname
  instance_count   = length(var.svcs.*.hostname)
  ignition         = var.ignition.svc_ignition
  num_cpu          = var.svc_num_cpu
  memory           = var.svc_memory
  disk_size        = var.svc_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.management.vsphere_datastore
  network          = var.management.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = var.management.upstreamdns1
  dns2             = var.management.upstreamdns2
  ip_addresses     = var.svcs.*.ipaddress
  gateway_ip       = var.management.defaultgw
  machine_cidr     = "${var.management.networkip}/${var.management.maskprefix}"
}

