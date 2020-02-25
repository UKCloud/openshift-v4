# Customer Tenant specific worker definitions 

//////////
// Worker Tenant machine variables
//////////

variable "worker_small_num_cpu" {
  type = string
  default = "2"
}

variable "worker_small_memory" {
  type = string
  description = "RAM size in megabytes"
  default = "8192"
}

variable "worker_small_disk_size" {
  type = string
  description = "Disk size in gigabytes"
  default = "60"
}

// Medium Workers
variable "worker_medium_num_cpu" {
  type = string
  default = "4"
}

variable "worker_medium_memory" {
  type = string
  description = "RAM size in megabytes"
  default = "16384"
}

variable "worker_medium_disk_size" {
  type = string
  description = "Disk size in gigabytes"
  default = "100"
}

// Large Workers
variable "worker_large_num_cpu" {
  type = string
  default = "8"
}

variable "worker_large_memory" {
  type = string
  description = "RAM size in megabytes"
  default = "32768"
}

variable "worker_large_disk_size" {
  type = string
  description = "Disk size in gigabytes"
  default = "100"
}

variable "smallworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress=""}]
}

variable "mediumworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress=""}]
}

variable "largeworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress=""}]
}

variable "tenant" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_folder = string,
                        vsphere_datastore = string,
                        vsphere_network = string,
                        vsphere_portgroup = string,
                        networkip = string,
                        maskprefix = string,
                        defaultgw = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string})
  description = "Network and vSphere parameters for tenant workers"
}

data "vsphere_resource_pool" "tenant_pool" {
  name             = var.customer.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
}

module "worker_small" {
  source = "./machine"

  names            = var.smallworkers.*.hostname
  instance_count   = length(var.smallworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.worker_small_num_cpu
  memory           = var.worker_small_memory
  disk_size        = var.worker_small_disk_size
  resource_pool_id = data.vsphere_resource_pool.tenant_pool.id
  folder           = var.tenant.vsphere_folder
  datastore        = var.tenant.vsphere_datastore
  network          = var.tenant.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns1 : var.svcs.*.ipaddress[0]
  dns2             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1]
  ip_addresses     = var.smallworkers.*.ipaddress
  gateway_ip       = var.tenant.defaultgw
  machine_cidr     = "${var.tenant.networkip}/${var.tenant.maskprefix}"
}

module "worker_medium" {
  source = "./machine"

  names            = var.mediumworkers.*.hostname
  instance_count   = length(var.mediumworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.worker_medium_num_cpu
  memory           = var.worker_medium_memory
  disk_size        = var.worker_medium_disk_size
  resource_pool_id = data.vsphere_resource_pool.tenant_pool.id
  folder           = var.tenant.vsphere_folder
  datastore        = var.tenant.vsphere_datastore
  network          = var.tenant.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns1 : var.svcs.*.ipaddress[0]
  dns2             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1]
  ip_addresses     = var.mediumworkers.*.ipaddress
  gateway_ip       = var.tenant.defaultgw
  machine_cidr     = "${var.tenant.networkip}/${var.tenant.maskprefix}"
}

module "worker_large" {
  source = "./machine"

  names            = var.largeworkers.*.hostname
  instance_count   = length(var.largeworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.worker_large_num_cpu
  memory           = var.worker_large_memory
  disk_size        = var.worker_large_disk_size
  resource_pool_id = data.vsphere_resource_pool.tenant_pool.id
  folder           = var.tenant.vsphere_folder
  datastore        = var.tenant.vsphere_datastore
  network          = var.tenant.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns1 : var.svcs.*.ipaddress[0]
  dns2             = length(var.svcs.*.hostname) == "0" ? var.management.upstreamdns2 : var.svcs.*.ipaddress[length(var.svcs.*.hostname) - 1]
  ip_addresses     = var.largeworkers.*.ipaddress
  gateway_ip       = var.tenant.defaultgw
  machine_cidr     = "${var.tenant.networkip}/${var.tenant.maskprefix}"
}
