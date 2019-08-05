provider "vsphere" {
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

module "folder" {
  source = "./folder"

  path          = "${var.cluster_id}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

module "resource_pool" {
  source = "./resource_pool"

  name            = "${var.cluster_id}"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
  vsphere_cluster = "${var.vsphere_cluster}"
}

module "bootstrap" {
  source = "./machine"

  name             = "bootstrap"
  instance_count   = "${var.bootstrap_complete ? 0 : 1}"
  ignition_url     = "${var.bootstrap_ignition_url}"
  num_cpu          = "${var.bootstrap_num_cpu}"
  memory           = "${var.bootstrap_memory}"
  disk_size        = "${var.bootstrap_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  datastore        = "${var.vsphere_datastore}"
  folder           = "${module.folder.path}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${compact(list(var.bootstrap_ip))}"]
  machine_cidr     = "${var.machine_cidr}"
}

module "master" {
  source = "./machine"

  name             = "master"
  instance_count   = "${var.master_count}"
  ignition         = "${var.master_ignition}"
  num_cpu          = "${var.master_num_cpu}"
  memory           = "${var.master_memory}"
  disk_size        = "${var.master_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${var.master_ips}"]
  machine_cidr     = "${var.machine_cidr}"
}

module "worker_small" {
  source = "./machine"

  name             = "worker-s"
  instance_count   = "${var.worker_small_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.worker_small_num_cpu}"
  memory           = "${var.worker_small_memory}"
  disk_size        = "${var.worker_small_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${var.worker_small_ips}"]
  machine_cidr     = "${var.machine_cidr}"
}

module "worker_medium" {
  source = "./machine"

  name             = "worker-m"
  instance_count   = "${var.worker_medium_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.worker_medium_num_cpu}"
  memory           = "${var.worker_medium_memory}"
  disk_size        = "${var.worker_medium_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${var.worker_medium_ips}"]
  machine_cidr     = "${var.machine_cidr}"
}

module "worker_large" {
  source = "./machine"

  name             = "worker-l"
  instance_count   = "${var.worker_large_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.worker_large_num_cpu}"
  memory           = "${var.worker_large_memory}"
  disk_size        = "${var.worker_large_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${var.worker_large_ips}"]
  machine_cidr     = "${var.machine_cidr}"
}

module "infra" {
  source = "./machine"

  name             = "infra"
  instance_count   = "${var.infra_count}"
  ignition         = "${var.worker_ignition}"
  num_cpu          = "${var.infra_num_cpu}"
  memory           = "${var.infra_memory}"
  disk_size        = "${var.infra_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${var.infra_ips}"]
  machine_cidr     = "${var.machine_cidr}"
}

module "svc" {
  source = "./machine"

  name             = "svc"
  instance_count   = "${var.svc_count}"
  ignition         = "${var.svc_ignition}"
  num_cpu          = "${var.svc_num_cpu}"
  memory           = "${var.svc_memory}"
  disk_size        = "${var.svc_disk_size}"
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${var.cluster_domain}"
  dns1             = "${var.dns1}"
  dns2             = "${var.dns2}"
  ipam             = "${var.ipam}"
  ipam_token       = "${var.ipam_token}"
  ip_addresses     = ["${var.svc_ips}"]
  machine_cidr     = "${var.machine_cidr}"
}

output "bootstrap" {
  value = [ zipmap(flatten(module.bootstrap.vm_names), flatten(module.bootstrap.ip_addresses)) ]
}

output "masters" {
  value = [ zipmap(flatten(module.master.vm_names), flatten(module.master.ip_addresses)) ]
}

output "small_workers" {
  value = [ zipmap(flatten(module.worker_small.vm_names), flatten(module.worker_small.ip_addresses)) ]
}

output "infras" {
  value = [ zipmap(flatten(module.infra.vm_names), flatten(module.infra.ip_addresses)) ]
}

output "svcs" {
  value = [ zipmap(flatten(module.svc.vm_names), flatten(module.svc.ip_addresses)) ]
}