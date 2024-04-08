# All variables used.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
#variable "compartment_ocid" {}
variable "region" {}
variable "availablity_domain_name" {
  default = ""
}
variable "compartment_ocid" {
  default = ""

}
variable "VCN-CIDR" {
  default = ""
}



variable "Subnet-CIDR1" {
  default = ""
}

variable "Subnet-CIDR2" {
  default = ""
}

variable "Subnet-CIDR3" {
  default = ""
}

variable "Subnet-CIDR4" {
  default = ""
}

variable "Subnet-CIDR5" {
  default = ""
}

variable "Shape" {
  default = "VM.Standard.E3.Flex"
}


variable "configuration_retention_period_days" {
  default = 90
}

variable "FlexShapeOCPUS" {
  default = 1
}

variable "FlexShapeMemory" {
  default = 1
}

variable "instance_os" {
  default = "Oracle Linux"
}

variable "linux_os_version" {
  default = "7.9"
}

variable "webservice_ports" {
  default = [80, 443, 22]
}

variable "bastion_ports" {
  default = ["22"]
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = 10
}

variable "flex_lb_max_shape" {
  default = 100
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
}


variable "sqlnet_ports" {
  default = [1521]
}

/*
variable "DBNodeShape" {
  default = "VM.Standard2.1"
}

variable "CPUCoreCount" {
  default = 1
}

variable "DBEdition" {
  default = "STANDARD_EDITION"
}

variable "DBAdminPassword" {
  default = ""
}

variable "DBName" {
  default = "APPSDB"
}

variable "DBVersion" {
  default = "19.17.0.0"
}

variable "DBDisplayName" {
  default = "APPSDB"
}


variable "DBDiskRedundancy" {
  default = "HIGH"
}


variable "DBSystemDisplayName" {
  default = "APPSDB"
}

variable "DBNodeDomainName" {
  default = ""
}

variable "DBNodeHostName" {
  default = "appsdb"
}

variable "HostUserName" {
  default = "opc"
}

variable "NCharacterSet" {
  default = "AL16UTF16"
}

variable "CharacterSet" {
  default = "AL32UTF8"
}

variable "DBWorkload" {
  default = "OLTP"
}

variable "PDBName" {
  default = "APPSPDB1"
}

variable "DataStorageSizeInGB" {
  default = 256
}

variable "LicenseModel" {
  default = "LICENSE_INCLUDED"
}

variable "NodeCount" {
  default = 1
}


variable "password" {
  type    = string
  default = ""
}
*/



variable "log_retention_duration" {
  type        = number
  default     = 30
  description = "Duration to retain logs"
}

variable "audit_retention_period_days" {
  type        = number
  default     = 90
  description = "Duration to retain logs"
}



variable "vcnloggroup" {
  type        = map(any)
  description = "Log Group"
  default = {
    "TEST" = "TEST"
  }
}

variable "vcn_id" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}


variable "log_group_id" {
  type    = string
  default = ""
}



variable "log_group_display_name" {
  default = "vcnloggroup"
}


variable "log_display_name" {
  default = "vcnlog"
}



variable "log_is_enabled" {
  default = "true"
}


variable "log_log_type" {
  default = "service"
}

/*
variable "vcn_id" {
  type        = string
  description = "VCN OCID"
}
*/

variable "service_logdef" {
  type        = map(any)
  description = "OCI Service log definition.Please refer doc for example definition"
  default     = {}
  validation {
    condition = (
      try(lookup(element(values(var.service_logdef), 0), "resource", null), {}) != null &&
      try(lookup(element(values(var.service_logdef), 0), "loggroup", null), {}) != null &&
    try(lookup(element(values(var.service_logdef), 0), "service", null), {}) != null)
    error_message = "All the keys like loggroup,service and resource are needed.Refer terraform.tfvars.example for reference."
  }
}

/*
variable "logdefinition" {
  type        = map(any)
  description = "Vcn Flow Log definition"
  default = {
    "vcnlogdef" = "vcnlogdef"
  }
}
*/



/*
variable "logdefinition" {
  #type        = map(any)
  #description = "Vcn Flow Log definition"
  default     = ""
}
*/



variable "logdefinition" {
  type        = map(any)
  description = "Vcn Flow Log definition"
  default     = {}
}




/*
variable "log_display_name" {
  description = "Map instance name to hostname"
  default = {
    "vcnlog" = "vcnlog"
    #"webpp2" = "webpp2"
    #"webpp3" = "webpp3"
    #"webpp4" = "webpp4"
    #"webpp5" = "webpp5"
  }
}
*/


variable "label_prefix" {
  description = "a string that will be prepended to all resources"
  type        = string
  default     = "none"
}


variable "create_service_gateway" {
  description = "whether to create a service gateway. If set to true, creates a service gateway."
  default     = true
  type        = bool
}

variable "log_source_resource" {
  default = ""
}





