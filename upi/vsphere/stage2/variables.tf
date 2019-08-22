//////
// vSphere variables
//////

variable "vsphere_server" {
  type        = "string"
  description = "This is the vSphere server for the environment."
}

variable "vsphere_user" {
  type        = "string"
  description = "vSphere server user for the environment."
}

variable "vsphere_password" {
  type        = "string"
  description = "vSphere server password"
}

variable "vsphere_cluster" {
  type        = "string"
  description = "This is the name of the vSphere cluster."
}

variable "vsphere_datacenter" {
  type        = "string"
  description = "This is the name of the vSphere data center."
}

variable "vsphere_datastore" {
  type        = "string"
  description = "This is the name of the vSphere data store."
}

variable "vsphere_folder" {
  type        = "string"
  description = "This is the name of the vSphere folder where the VMs are to be created"
}

variable "vsphere_resourcepool" {
  type        = "string"
  description = "This is the name of the vSphere resource pool where the VMs are to be created"
}

variable "vm_template" {
  type        = "string"
  description = "This is the name of the VM template to clone."
}

variable "dns1" {
  type        = "string"
  description = "This is the primary dns server for the cluster; node names must be resolvable by this"
  default     = ""
}

variable "dns2" {
  type        = "string"
  description = "This is the secondary dns server for the cluster; node names must be resolvable by this"
  default     = ""
}

/////////
// OpenShift cluster variables
/////////

variable "cluster_id" {
  type        = "string"
  description = "This cluster id must be of max length 27 and must have only alphanumeric or hyphen characters."
}

variable "base_domain" {
  type        = "string"
  description = "The base DNS zone to add the sub zone to."
}

variable "cluster_domain" {
  type        = "string"
  description = "The base DNS zone to add the sub zone to."
}

variable "network_cidr" {
  type = "string"
  description = "The internal network address in #.#.#.0/24 format."
}

variable "gateway_ip" {
  type    = "string"
  description = "The default gw in the internal subnet."
}

/////////
// Bootstrap machine variables
/////////

variable "bootstrap_complete" {
  type    = "string"
  default = "false"
}

variable "bootstrap_ignition_url" {
  type = "string"
}

variable "bootstrap_start_ip" {
  type    = number
  default = 250
}

variable "bootstrap_ip" {
  type    = "string"
  default = ""
}

variable "bootstrap_num_cpu" {
  type = "string"
  default = "1"
}

variable "bootstrap_memory" {
  type = "string"
  default = "2048"
}

variable "bootstrap_disk_size" {
  type = "string"
  default = "60"
}


///////////
// Master machine variables
///////////

variable "master_count" {
  type    = "string"
  default = "3"
}

variable "master_ignition" {
  type = "string"
}

variable "master_start_ip" {
  type    = number
  default = 10
}

variable "master_ips" {
  type    = "list"
  default = []
}

variable "master_num_cpu" {
  type = "string"
  default = "4"
}

variable "master_memory" {
  type = "string"
  default = "12228"
}

variable "master_disk_size" {
  type = "string"
  default = "60"
}

//////////
// Worker Tenant machine variables
//////////

variable "worker_ignition" {
  type = "string"
  description = "All workers inc infras share the same ignition config"
}

// Small Workers
variable "worker_small_count" {
  type    = "string"
  default = "0"
}

variable "worker_small_start_ip" {
  type    = number
  default = 25
}

variable "worker_small_ips" {
  type    = "list"
  default = []
}

variable "worker_small_num_cpu" {
  type = "string"
  default = "2"
}

variable "worker_small_memory" {
  type = "string"
  description = "RAM size in megabytes"
  default = "8192"
}

variable "worker_small_disk_size" {
  type = "string"
  description = "Disk size in gigabytes"
  default = "60"
}

// Medium Workers
variable "worker_medium_count" {
  type    = "string"
  default = "0"
}

variable "worker_medium_start_ip" {
  type    = number
  default = 83
}

variable "worker_medium_ips" {
  type    = "list"
  default = []
}

variable "worker_medium_num_cpu" {
  type = "string"
  default = "4"
}

variable "worker_medium_memory" {
  type = "string"
  description = "RAM size in megabytes"
  default = "8192"
}

variable "worker_medium_disk_size" {
  type = "string"
  description = "Disk size in gigabytes"
  default = "60"
}

// Large Workers
variable "worker_large_count" {
  type    = "string"
  default = "0"
}

variable "worker_large_start_ip" {
  type    = number
  default = 141
}

variable "worker_large_ips" {
  type    = "list"
  default = []
}

variable "worker_large_num_cpu" {
  type = "string"
  default = "8"
}

variable "worker_large_memory" {
  type = "string"
  description = "RAM size in megabytes"
  default = "16384"
}

variable "worker_large_disk_size" {
  type = "string"
  description = "Disk size in gigabytes"
  default = "60"
}

// Infra Workers
variable "infra_count" {
  type    = "string"
  default = "0"
}

variable "infra_ignition" {
  type = "string"
}

variable "infra_start_ip" {
  type    = number
  default = 15
}

variable "infra_ips" {
  type    = "list"
  default = []
}

variable "infra_num_cpu" {
  type = "string"
  default = "2"
}

variable "infra_memory" {
  type = "string"
  description = "RAM size in megabytes"
  default = "8192"
}

variable "infra_disk_size" {
  type = "string"
  description = "Disk size in gigabytes"
  default = "60"
}


///////////
// Service machine variables
///////////

variable "svc_count" {
  type    = "string"
  default = "0"
}

variable "svc_ignition" {
  type = "string"
  default = ""
}

variable "svc_start_ip" {
  type    = number
  default = 5
}

variable "svc_ips" {
  type    = "list"
  default = []
}

variable "svc_num_cpu" {
  type = "string"
  default = "1"
}

variable "svc_memory" {
  type = "string"
  description = "RAM size in megabytes"
  default = "2048"
}

variable "svc_disk_size" {
  type = "string"
  description = "Disk size in gigabytes"
  default = "60"
}


// Variables defined to match the format of config.json (named terraform.tfvars.json)
/////////
// OpenShift cluster variables
/////////

variable "clusterid" {
  type        = "string"
  description = "This cluster id must be of max length 27 and must have only alphanumeric or hyphen characters."
}

variable "basedomain" {
  type        = "string"
  description = "The base DNS zone to add the sub zone to."
}

// clusterdomain = $clusterid + "." + $basedomain

variable "bootstrap" {
  type        = object({hostname = string,
                        ipaddress = string})
}

variable "svcs" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}


variable "masters" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}


variable "infras" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}


variable "smallworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "mediumworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "largeworkers" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress="" }]
}

variable "network" {
  type        = object({networkip = string, 
                        maskprefix = string, 
                        defaultgw = string, 
                        upstreamdns1 = string, 
                        upstreamdns2 = string })
  description = "Network parameters"
}

// network_cidr = $networkip + "/" + $maskprefix


variable "loadbalancer" {
  type        = object({externalvip = string,
                        internalvip = string})
}

variable "sshpubkey" {
  type        = "string"
  description = "This is the SSH key installed to allow access to the VMs"
}

variable "vsphere" {
  type        = object({vsphere_server = string, 
                        vsphere_cluster = string, 
                        vsphere_resourcepool = string, 
                        vsphere_folder = string, 
                        vsphere_datacenter = string, 
                        vsphere_datastore = string, 
                        vsphere_network = string, 
                        rhcos_template = string})
  description = "vSphere-specific parameters"
}
