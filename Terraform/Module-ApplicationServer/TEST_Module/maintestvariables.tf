# All variables used.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
#variable "compartment_ocid" {}
variable "region" {}


variable "ad_number" {
  default = "0"
}


##webtest1 variable parameters
variable "instance_availability_domain" {
  default = "1"
}




variable "boot_volume_size_in_gbs" {
  default = "100" # size in GBs
}

variable "blockvolume_size" {
  default = "200" # size in GBs
}

/*
variable "bootvolume4_size" {
  default = "100" # size in GBs
}
*/


/*
variable "bootvolume4_size" {
  default = "100" # size in GBs
}
*/

/*
variable "blockvolume1_size" {
  default = "200" # size in GBs
}

variable "blockvolume4_size" {
  default = "200" # size in GBs
}
*/


/*
variable "blockvolume4_size" {
  default = "200" # size in GBs
}
*/



/*
variable "fss_count" {
  description = "Number of identical instances to launch from a single module."
  type        = number
  default     = 2
}

variable "fss_display_name" {
  description = "(Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable."
  type        = string
  default     = "webtest"
}
*/




variable "compartment_ocid" {
  default = ""
}

variable "vcn_ocid" {
  default = ""
}

variable "subnet_id" {
  default = ""
}



variable "private_route_table_display_name" {
  default = "PrivateRouteTable"
} // Name for the private routetable


variable "natgw_route_cidr_block" {
  default = ""
}





variable "VCN-CIDR" {
  default = ""
}

variable "Subnet-CIDR" {
  default = ""
}



// INSTANCE VARIABLES

variable "shape_name" {
  default = "VM.Standard.E4.Flex"
}


variable "instance_flex_ocpus" {
  default = 4
}

variable "instance_flex_memory_in_gbs" {
  default = 24
}



/*
variable "instance_os" {
  default = "Oracle Linux"
}

variable "linux_os_version" {
  default = "7.9"
}
*/


variable "service_ports" {
  default = [80, 443, 22]
}

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
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
}
*/





variable "ssh_key_private" {
  default = "/home/opc/.ssh/id_rsa"
}

/*
locals {
  mount_target_1_ip_address = data.oci_core_private_ips.ip_mount_target1.private_ips[0]["ip_address"]
}
*/


variable "instance_image_ocid" {
  type = map(string)
  default = {
    eu-frankfurt-1 = ""
  }

}
variable "source_type" {
  default = "image"
}


variable "instance_variables" {
  description = "Map instance name to hostname"
  default = {
    "test1" = "test1"

  }
}

variable "blockvolume_variables" {
  description = "Map instance name to blockvolume"
  default = {
    "test1" = "testblockvolume1"

  }
}


variable "MountTargetIPAddress" {
  default = ""
}





variable "exportset_variables" {
  description = "Map instance name to exportset"
  default = {
    "Exportset1" = "Exportset1"

  }
}

variable "filesystem_variables" {
  description = "Map instance name to filesystem"
  default = {
    "Filesystem1" = "Filesystem1"

  }
}


variable "exportpath_variables" {
  description = "Map instance name to exportpath"
  default = {
    "/fs1" = "/fs1"

  }
}


variable "volume_is_auto_tune_enabled" {
  // for future use, adding block volume performance auto-tune
  description = "(Optional) (Updatable) Specifies whether the auto-tune performance is enabled for this volume."
  type        = bool
  default     = true
}



variable "instance_create_vnic_details_hostname_label" {
  default = "test"
}

variable "instance_create_vnic_details_skip_source_dest_check" {
  default = false
}

