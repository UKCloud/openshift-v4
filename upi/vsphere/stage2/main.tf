provider "vsphere" {
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_resource_pool" "pool" {
  name             = "${var.vsphere_resourcepool}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
}


module "bootstrap" {
  source = "./machine"

  names            = ["${var.bootstrap.hostname}"]
  instance_count   = "${var.bootstrap_complete ? 0 : 1}"
  ignition_url     = "${var.bootstrap_ignition_url}"
  num_cpu          = "${var.bootstrap_num_cpu}"
  memory           = "${var.bootstrap_memory}"
  disk_size        = "${var.bootstrap_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore        = "${var.vsphere_datastore}"
  folder           = "${var.vsphere_folder}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.svc_count == "0" ? var.dns1 : var.svc_ips[0] }"
  dns2             = "${var.svc_count == "0" ? var.dns2 : var.svc_ips[var.svc_count - 1] }"
  ip_addresses     = ["${var.bootstrap.ipaddress}"]
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

module "master" {
  source = "./machine"

  names            = "${var.masters.*.hostname}"
  instance_count   = "${var.master_count}"
  ignition         = "${var.master_ignition}"
  num_cpu          = "${var.master_num_cpu}"
  memory           = "${var.master_memory}"
  disk_size        = "${var.master_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.vsphere_folder}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.svc_count == "0" ? var.dns1 : var.svc_ips[0] }"
  dns2             = "${var.svc_count == "0" ? var.dns2 : var.svc_ips[var.svc_count - 1] }"
  ip_addresses     = "${var.masters.*.ipaddress}"
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

module "worker_small" {
  source = "./machine"

  names            = "${var.smallworkers.*.hostname}"
  instance_count   = "${var.worker_small_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.worker_small_num_cpu}"
  memory           = "${var.worker_small_memory}"
  disk_size        = "${var.worker_small_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.vsphere_folder}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.svc_count == "0" ? var.dns1 : var.svc_ips[0] }"
  dns2             = "${var.svc_count == "0" ? var.dns2 : var.svc_ips[var.svc_count - 1] }"
  ip_addresses     = "${var.smallworkers.*.ipaddress}"
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

module "worker_medium" {
  source = "./machine"

  names            = "${var.mediumworkers.*.hostname}"
  instance_count   = "${var.worker_medium_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.worker_medium_num_cpu}"
  memory           = "${var.worker_medium_memory}"
  disk_size        = "${var.worker_medium_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.vsphere_folder}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.svc_count == "0" ? var.dns1 : var.svc_ips[0] }"
  dns2             = "${var.svc_count == "0" ? var.dns2 : var.svc_ips[var.svc_count - 1] }"
  ip_addresses     = "${var.mediumworkers.*.ipaddress}"
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

module "worker_large" {
  source = "./machine"

  names            = "${var.largeworkers.*.hostname}"
  instance_count   = "${var.worker_large_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.worker_large_num_cpu}"
  memory           = "${var.worker_large_memory}"
  disk_size        = "${var.worker_large_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.vsphere_folder}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.svc_count == "0" ? var.dns1 : var.svc_ips[0] }"
  dns2             = "${var.svc_count == "0" ? var.dns2 : var.svc_ips[var.svc_count - 1] }"
  ip_addresses     = "${var.largeworkers.*.ipaddress}"
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

module "infra" {
  source = "./machine"

  names            = "${var.infras.*.hostname}"
  instance_count   = "${var.infra_count}"
  ignition         = "${var.infra_ignition}"
  num_cpu          = "${var.infra_num_cpu}"
  memory           = "${var.infra_memory}"
  disk_size        = "${var.infra_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.vsphere_folder}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.svc_count == "0" ? var.dns1 : var.svc_ips[0] }"
  dns2             = "${var.svc_count == "0" ? var.dns2 : var.svc_ips[var.svc_count - 1] }"
  ip_addresses     = "${var.infras.*.ipaddress}"
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

module "svc" {
  source = "./machine"

  names            = "${var.svcs.*.hostname}"
  instance_count   = "${var.svc_count}"
  ignition         = "${var.svc_ignition}"
  num_cpu          = "${var.svc_num_cpu}"
  memory           = "${var.svc_memory}"
  disk_size        = "${var.svc_disk_size}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.vsphere_folder}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vsphere.vsphere_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ip_addresses     = "${var.svcs.*.ipaddress}"
  gateway_ip       = "${var.gateway_ip}"
  machine_cidr     = "${var.network_cidr}"
}

