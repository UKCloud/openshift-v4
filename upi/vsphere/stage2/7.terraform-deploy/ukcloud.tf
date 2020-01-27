### Variables specific to UKCloud Internal Deployments

variable "assured" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_folder = string,
                        vsphere_datacenter = string,
                        vsphere_datastore = string,
                        vsphere_network = string,
                        vsphere_portgroup = string,
                        rhcos_template = string,
                        network_default_gateway = string,
                        networkip = string,
                        network_maskprefix = string,
                        dns1 = string,
                        dns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Assured-specific parameters"
}

variable "elevated" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_folder = string,
                        vsphere_datacenter = string,
                        vsphere_datastore = string,
                        vsphere_network = string,
                        vsphere_portgroup = string,
                        rhcos_template = string,
                        network_default_gateway = string,
                        networkip = string,
                        network_maskprefix = string,
                        dns1 = string,
                        dns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Elevated-specific parameters"
}

variable "assuredworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "elevatedworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}




# Assured/Elevated specific vCenter params

data "vsphere_datacenter" "assured_dc" {
  name = var.assured.vsphere_datacenter
}

data "vsphere_resource_pool" "assured_pool" {
  name             = var.assured.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.assured_dc.id
}

data "vsphere_datacenter" "elevated_dc" {
  name = var.elevated.vsphere_datacenter
}

data "vsphere_resource_pool" "elevated_pool" {
  name             = var.elevated.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.elevated_dc.id
}




# Assured workers

module "worker_assured" {
  source = "./machine"

  names            = var.assuredworkers.*.hostname
  instance_count   = length(var.assuredworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.assured.num_cpu
  memory           = var.assured.memory
  disk_size        = var.assured.disk_size
  resource_pool_id = data.vsphere_resource_pool.assured_pool.id
  folder           = var.assured.vsphere_folder
  datastore        = var.assured.vsphere_datastore
  network          = var.assured.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.assured_dc.id
  template         = var.assured.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = assured.dns1
  dns2             = assured.dns2
  ip_addresses     = var.assuredworkers.*.ipaddress
  gateway_ip       = var.assured.defaultgw
  machine_cidr     = "${var.assured.networkip}/${var.assured.maskprefix}"
}


# Elevated workers

module "worker_elevated" {
  source = "./machine"

  names            = var.elevatedworkers.*.hostname
  instance_count   = length(var.elevatedworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.elevated.num_cpu
  memory           = var.elevated.memory
  disk_size        = var.elevated.disk_size
  resource_pool_id = data.vsphere_resource_pool.elevated_pool.id
  folder           = var.elevated.vsphere_folder
  datastore        = var.elevated.vsphere_datastore
  network          = var.elevated.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.elevated_dc.id
  template         = var.elevated.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = elevated.dns1
  dns2             = elevated.dns2
  ip_addresses     = var.elevatedworkers.*.ipaddress
  gateway_ip       = var.elevated.defaultgw
  machine_cidr     = "${var.elevated.networkip}/${var.elevated.maskprefix}"
}
