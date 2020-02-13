# Fix provider version; ignition 1.2 appears to break deployment
terraform {
  required_providers {
    ignition = "= 1.1"
    vsphere = "= 1.13"
  }
}


provider "vsphere" {
  user                 = var.vcenterdeploy.username
  password             = var.vcenterdeploy.password
  vsphere_server       = var.vsphere.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere.vsphere_datacenter
}

data "vsphere_resource_pool" "pool" {
  name             = var.vsphere.vsphere_resourcepool
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
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore        = var.vsphere.vsphere_datastore
  folder           = var.vsphere.vsphere_folder
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = [var.bootstrap.ipaddress]
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

module "master" {
  source = "./machine"

  names            = var.masters.*.hostname
  instance_count   = length(var.masters.*.hostname)
  ignition         = var.ignition.master_ignition
  num_cpu          = var.master_num_cpu
  memory           = var.master_memory
  disk_size        = var.master_disk_size
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.vsphere.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.masters.*.ipaddress
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

module "worker_small" {
  source = "./machine"

  names            = var.smallworkers.*.hostname
  instance_count   = length(var.smallworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.worker_small_num_cpu
  memory           = var.worker_small_memory
  disk_size        = var.worker_small_disk_size
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.vsphere.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.smallworkers.*.ipaddress
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

module "worker_medium" {
  source = "./machine"

  names            = var.mediumworkers.*.hostname
  instance_count   = length(var.mediumworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.worker_medium_num_cpu
  memory           = var.worker_medium_memory
  disk_size        = var.worker_medium_disk_size
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.vsphere.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.mediumworkers.*.ipaddress
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

module "worker_large" {
  source = "./machine"

  names            = var.largeworkers.*.hostname
  instance_count   = length(var.largeworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.worker_large_num_cpu
  memory           = var.worker_large_memory
  disk_size        = var.worker_large_disk_size
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.vsphere.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.largeworkers.*.ipaddress
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

module "infra" {
  source = "./machine"

  names            = var.infras.*.hostname
  instance_count   = length(var.infras.*.hostname)
  ignition         = var.ignition.infra_ignition
  num_cpu          = var.infra_num_cpu
  memory           = var.infra_memory
  disk_size        = var.infra_disk_size
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.vsphere.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns1 : var.svcs.*.ipaddress[0] 
  dns2             = length(var.svcs.*.hostname) == "0" ? var.network.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1] 
  ip_addresses     = var.infras.*.ipaddress
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

module "svc" {
  source = "./machine"

  names            = var.svcs.*.hostname
  instance_count   = length(var.svcs.*.hostname)
  ignition         = var.ignition.svc_ignition
  num_cpu          = var.svc_num_cpu
  memory           = var.svc_memory
  disk_size        = var.svc_disk_size
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.vsphere.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = var.network.upstreamdns1
  dns2             = var.network.upstreamdns2
  ip_addresses     = var.svcs.*.ipaddress
  gateway_ip       = var.network.defaultgw
  machine_cidr     = "${var.network.networkip}/${var.network.maskprefix}"
  transit_network  = var.vsphere.vsphere_transit_portgroup
  transit_gateway_ip = var.transitnetwork.defaultgw
  transit_cidr     = "${var.transitnetwork.networkip}/${var.transitnetwork.maskprefix}"
  transit_ip_addresses = []
}

