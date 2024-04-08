# All variables used.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "availablity_domain_name" {
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

variable "Shape" {
  default = "VM.Optimized3.Flex"
}


variable "configuration_retention_period_days" {
  default = 90
}

variable "FlexShapeOCPUS" {
  default = 1
}

variable "FlexShapeMemory" {
  default = 8
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
  is_flexible_shape    = contains(local.compute_flexible_shapes, var.Shape)
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}



variable "sqlnet_ports" {
  default = [1521, 8080]
}


variable "DBNodeShape" {
  default = "VM.Standard.E4.Flex"
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
  default = "ApexTemp"
}

variable "DBVersion" {
  default = "19.0.0.0"
}

variable "DBDisplayName" {
  default = "ApexTemp"
}


variable "DBDiskRedundancy" {
  default = "HIGH"
}



variable "DBSystemDisplayName" {
  default = "ApexTemp"
}

variable "DBNodeDomainName" {
  default = ""
}

variable "DBNodeHostName" {
  default = "apextemp"
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
  default = "ApexTempPDB1"
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


/*
variable "volume_size_in_gbs" {
  default = 100
}
*/

/*
# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}
*/


/*
# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_shape    = contains(local.compute_flexible_shapes, var.Shape)
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}
*/

variable "create_service_gateway" {
  description = "whether to create a service gateway. If set to true, creates a service gateway."
  default     = true
  type        = bool
}

/*
variable "ssl_certificate_private_key_path" {
  description = "Path to the SSL certificate private key file."
}

variable "ssl_certificate_public_key_path" {
  description = "Path to the SSL certificate public key file."
}
*/

variable "apps_csr" {
  default = ""
}

variable "apps_privatekey" {
  default = ""

}

variable "backup_enabled" {
  // Enable automatic backups
  default = true
}





