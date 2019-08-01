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
  num_cpu          = "2"
  memory           = "2048"
  disk_size        = "60"
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
  num_cpu          = "8"
  memory           = "8192"
  disk_size        = "60"  
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
  num_cpu          = "2"
  memory           = "4096"
  disk_size        = "60"
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

