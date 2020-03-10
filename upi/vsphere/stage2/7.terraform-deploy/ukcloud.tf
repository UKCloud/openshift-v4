### Variables specific to UKCloud Internal Deployments

variable "assured" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_datastore = string,
                        defaultgw = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Assured-specific parameters"
}

variable "assured_public" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_datastore = string,
                        defaultgw = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Assured-public-specific parameters"
}

variable "combined" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_datastore = string,
                        defaultgw  = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Combined-specific parameters"
}

variable "elevated" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_datastore = string,
                        defaultgw  = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Elevated-specific parameters"
}

variable "elevated_public" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_datastore = string,
                        defaultgw  = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string,
                        num_cpu = string,
                        memory = string,
                        disk_size = string })
  description = "Elevated-public-specific parameters"
}

variable "assuredworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "assuredsvcs" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "assuredpublicworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "combinedworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "combinedsvcs" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "elevatedworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "elevatedsvcs" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "elevatedpublicworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}




# Assured/Elevated specific vCenter params

data "vsphere_resource_pool" "assured_pool" {
  name             = var.assured.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "assured_public_pool" {
  name             = var.assured_public.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "combined_pool" {
  name             = var.combined.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "elevated_pool" {
  name             = var.elevated.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "elevated_public_pool" {
  name             = var.elevated_public.vsphere_resourcepool
  datacenter_id    = data.vsphere_datacenter.dc.id
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
  folder           = var.vsphere.vsphere_folder
  datastore        = var.assured.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.assuredsvcs.*) == "0" ? var.assured.upstreamdns1 : var.assuredsvcs.*.ipaddress[0]
  dns2             = length(var.assuredsvcs.*) == "0" ? var.assured.upstreamdns2 : var.assuredsvcs.*.ipaddress[length(var.assuredsvcs.*.hostname) - 1]
  ip_addresses     = var.assuredworkers.*.ipaddress
  gateway_ip       = var.assured.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}

module "worker_assured_public" {
  source = "./machine"

  names            = var.assuredpublicworkers.*.hostname
  instance_count   = length(var.assuredpublicworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.assured_public.num_cpu
  memory           = var.assured_public.memory
  disk_size        = var.assured_public.disk_size
  resource_pool_id = data.vsphere_resource_pool.assured_public_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.assured_public.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.assuredsvcs.*) == "0" ? var.assured_public.upstreamdns1 : var.assuredsvcs.*.ipaddress[0]
  dns2             = length(var.assuredsvcs.*) == "0" ? var.assured_public.upstreamdns2 : var.assuredsvcs.*.ipaddress[length(var.assuredsvcs.*.hostname) - 1]
  ip_addresses     = var.assuredpublicworkers.*.ipaddress
  gateway_ip       = var.assured_public.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}

# Assured svcs/DNS - currently also used for Assured Public
module "svc_assured" {
  source = "./machine"

  names            = var.assuredsvcs.*.hostname
  instance_count   = length(var.assuredsvcs.*.hostname)
  ignition         = var.ignition.svc_ignition
  num_cpu          = var.svc_num_cpu
  memory           = var.svc_memory
  disk_size        = var.svc_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.assured.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = var.assured.upstreamdns1
  dns2             = var.assured.upstreamdns2
  ip_addresses     = var.assuredsvcs.*.ipaddress
  gateway_ip       = var.assured.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}


# Combined workers
module "worker_combined" {
  source = "./machine"

  names            = var.combinedworkers.*.hostname
  instance_count   = length(var.combinedworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.combined.num_cpu
  memory           = var.combined.memory
  disk_size        = var.combined.disk_size
  resource_pool_id = data.vsphere_resource_pool.combined_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.combined.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.combinedsvcs) == "0" ? var.combined.upstreamdns1 : var.combinedsvcs.*.ipaddress[0]
  dns2             = length(var.combinedsvcs) == "0" ? var.combined.upstreamdns2 : var.combinedsvcs.*.ipaddress[length(var.combinedsvcs.*.hostname) - 1]
  ip_addresses     = var.combinedworkers.*.ipaddress
  gateway_ip       = var.combined.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}

# Combined svcs/DNS
module "svc_combined" {
  source = "./machine"

  names            = var.combinedsvcs.*.hostname
  instance_count   = length(var.combinedsvcs.*.hostname)
  ignition         = var.ignition.svc_ignition
  num_cpu          = var.svc_num_cpu
  memory           = var.svc_memory
  disk_size        = var.svc_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.combined.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = var.combined.upstreamdns1
  dns2             = var.combined.upstreamdns2
  ip_addresses     = var.combinedsvcs.*.ipaddress
  gateway_ip       = var.combined.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
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
  folder           = var.vsphere.vsphere_folder
  datastore        = var.elevated.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.elevatedsvcs) == "0" ? var.elevated.upstreamdns1 : var.elevatedsvcs.*.ipaddress[0]
  dns2             = length(var.elevatedsvcs) == "0" ? var.elevated.upstreamdns2 : var.elevatedsvcs.*.ipaddress[length(var.elevatedsvcs.*.hostname) - 1]
  ip_addresses     = var.elevatedworkers.*.ipaddress
  gateway_ip       = var.elevated.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}

module "worker_elevated_public" {
  source = "./machine"

  names            = var.elevatedpublicworkers.*.hostname
  instance_count   = length(var.elevatedpublicworkers.*.hostname)
  ignition         = var.ignition.worker_ignition
  num_cpu          = var.elevated_public.num_cpu
  memory           = var.elevated_public.memory
  disk_size        = var.elevated_public.disk_size
  resource_pool_id = data.vsphere_resource_pool.elevated_public_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.elevated_public.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = length(var.elevatedsvcs) == "0" ? var.elevated_public.upstream_dns1 : var.elevatedsvcs.*.ipaddress[0]
  dns2             = length(var.elevatedsvcs) == "0" ? var.elevated_public.upstream_dns2 : var.elevatedsvcs.*.ipaddress[length(var.elevatedsvcs.*.hostname) - 1]
  ip_addresses     = var.elevatedpublicworkers.*.ipaddress
  gateway_ip       = var.elevated_public.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}

# Elevated svcs/DNS - currently also used for Elevated Public
module "svc_elevated" {
  source = "./machine"

  names            = var.elevatedsvcs.*.hostname
  instance_count   = length(var.elevatedsvcs.*.hostname)
  ignition         = var.ignition.svc_ignition
  num_cpu          = var.svc_num_cpu
  memory           = var.svc_memory
  disk_size        = var.svc_disk_size
  resource_pool_id = data.vsphere_resource_pool.management_pool.id
  folder           = var.vsphere.vsphere_folder
  datastore        = var.elevated.vsphere_datastore
  network          = var.vsphere.vsphere_portgroup
  datacenter_id    = data.vsphere_datacenter.dc.id
  template         = var.vsphere.rhcos_template
  cluster_domain   = "${var.clusterid}.${var.basedomain}"
  dns1             = var.assured.upstreamdns1
  dns2             = var.assured.upstreamdns2
  ip_addresses     = var.elevatedsvcs.*.ipaddress
  gateway_ip       = var.elevated.defaultgw
  machine_cidr     = "${var.vsphere.networkip}/${var.vsphere.maskprefix}"
}

