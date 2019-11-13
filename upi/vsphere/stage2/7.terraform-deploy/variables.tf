
/////////
// Bootstrap machine variables
/////////

variable "bootstrap_complete" {
  type    = "string"
  default = "false"
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


// Bastion isn't created here, but included to avoid input errors for undeclared
variable "bastion" {
  type        = object({hostname = string,
                        ipaddress = string})
}

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

// Ignition config

variable "ignition" {
  type        = object({bootstrap_ignition_url = string, 
                        master_ignition = string, 
                        worker_ignition = string, 
                        infra_ignition = string, 
                        svc_ignition = string}) 
  description = "Igntion config (configs need to be JSON escaped"
}


// Authentication from secrets.auto.tfvars.json

variable "vcenterdeploy" {
  type        = object({username = string, 
                        password = string})
  description = "vCenter creds for deployer only"
}

// Add rhpullsecret to avoid warning/error

variable "rhpullsecret" {
  type        = "string"
  description = "RH pull secret. Not required but defined to avoid warning"
}
