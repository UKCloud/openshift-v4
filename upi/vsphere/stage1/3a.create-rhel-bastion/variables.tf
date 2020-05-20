
/////////
// Bootstrap machine variables
/////////

variable "bootstrap_complete" {
  type    = string
  default = "false"
}

variable "bootstrap_num_cpu" {
  type = string
  default = "2"
}

variable "bootstrap_memory" {
  type = string
  default = "8192"
}

variable "bootstrap_disk_size" {
  type = string
  default = "60"
}


///////////
// Master machine variables
///////////


variable "master_num_cpu" {
  type = string
  default = "4"
}

variable "master_memory" {
  type = string
  default = "16384"
}

variable "master_disk_size" {
  type = string
  default = "60"
}

// Infra Workers
variable "infra_num_cpu" {
  type = string
  default = "4"
}

variable "infra_memory" {
  type = string
  description = "RAM size in megabytes"
  default = "16384"
}

variable "infra_disk_size" {
  type = string
  description = "Disk size in gigabytes"
  default = "60"
}


///////////
// Service machine variables
///////////
variable "svc_num_cpu" {
  type = string
  default = "1"
}

variable "svc_memory" {
  type = string
  description = "RAM size in megabytes"
  default = "1024"
}

variable "svc_disk_size" {
  type = string
  description = "Disk size in gigabytes"
  default = "60"
}


// Variables defined to match the format of config.json (named terraform.tfvars.json)
/////////
// OpenShift cluster variables
/////////

variable "clusterid" {
  type        = string
  description = "This cluster id must be of max length 27 and must have only alphanumeric or hyphen characters."
}

variable "basedomain" {
  type        = string
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
  default     = [{ hostname="",ipaddress=""}]
}


variable "masters" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress=""}]
}


variable "infras" {
  type        = list(object({hostname = string,
                        ipaddress = string}))
  default     = [{ hostname="",ipaddress=""}]
}

variable "sshpubkey" {
  type        = string
  description = "This is the SSH key installed to allow access to the VMs"
}

variable "vsphere" {
  type        = object({vsphere_server = string, 
                        vsphere_cluster = string, 
                        vsphere_datacenter = string, 
                        vsphere_folder = string,
                        vsphere_network = string,
                        vsphere_portgroup = string,
                        networkip = string,
                        maskprefix = string,
                        rhcos_template = string,
                        rhel_template = string})
  description = "Shared vSphere parameters"
}

variable "management" {
  type        = object({vsphere_resourcepool = string,
                        vsphere_datastore = string,
                        defaultgw = string,
                        upstreamdns1 = string,
                        upstreamdns2 = string})
  description = "Network and vSphere parameters for management VMs"
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

variable "vcentervolumeprovisioner" {
  type        = object({username = string,
                        password = string})
  description = "vCenter creds for cloud provider volume provisioning"
}

variable "dns" {
  type        = object({username = string,
                        password = string})
  description = "dns creds for LetsEncrypt"
}

variable "objectstorage" {
  type        = object({accesskey = string,
                        secretkey = string,
                        bucketname = string,
                        regionendpoint = string})
  description = "Object storage credentials for Image Registry"
}

// Add params to avoid warning/error

variable "rhpullsecret" {
  type        = map
  description = "RH pull secret. Not required but defined to avoid warning"
}

variable "registrytoken" {
  type        = string
  description = "registry token. Not required but defined to avoid warning"
}

variable "registryurl" {
  type        = string
  description = "registry url. Not required but defined to avoid warning"
}

variable "imagetag" {
  type        = string
  description = "image version tag. Not required but defined to avoid warning"
}

variable "registryusername" {
  type        = string
  description = "Username to connect to registry. Not required but defined to avoid warning"
}

variable "useletsencrypt" {
  type        = string
  description = "Switch to enable Lets Encrypt certs. Not required but defined to avoid warning"
}

variable "additionalca" {
  type        = string
  description = "ca for accessing disconnected install registry"
}

variable "imagesources" {
  type        = string
  description = "sources string for disconnected"
}

variable "satellitefqdn" {
  type        = string
  description = "Address of satellite server to sub RHEL. Not required but defined to avoid warning"
}

variable "rhnorgid" {
  type        = string
  description = "Org ID for satellite server to sub RHEL. Not required but defined to avoid warning"
}

variable "rhnactivationkey" {
  type        = string
  description = "Activation Key for satellite server to sub RHEL. Not required but defined to avoid warning"
}

variable "rheltemplatepw" {
  type        = string
  description = "root password for the RHEL template. Not required but defined to avoid warning"
}

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

