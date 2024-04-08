
variable "compartment_ocid" {}
variable "vcn_id" {}
#variable "instance_availability_domain" {}
#variable "availablity_domain_name3" {}
#variable "shape_id" {}
#variable "shape_name" {}
#variable "image_id" {}
#variable "subnet_id" {}
#variable "region" {}
#variable "ssh_key_private" {}
#variable "instance_image_ocid" {}
#variable "instance_flex_ocpus" {}
#variable "instance_flex_memory_in_gbs" {}
#variable "boot_volume_size_in_gbs" {}
#variable "blockvolume_size" {}
#variable "ssh_public_key" {}
#variable "assign_public_ip" {}
#variable "MountTargetIPAddress" {}
#variable "instance_variables" { type = map(string) }
#variable "blockvolume_variables" { type = map(string) }
#variable "webppmounttarget_variables" { type = map(string) }
#variable "webppexportset_variables" { type = map(string) }
#variable "webppfilesystem_variables" { type = map(string) }
#variable "webppexportpath_variables" { type = map(string) }
#variable "instance_display" { type = map(string) }
#variable "instance_create_vnic_details_hostname_label" {}
#variable "instance_create_vnic_details_skip_source_dest_check" {}
#variable "volume_is_auto_tune_enabled" {}
#variable "instance_display_name" {}
#variable "instance_count" {}
#variable "vnic_name" {}
#variable "hostname_label" {}
#variable "private_ips" {}
#variable "skip_source_dest_check" {}
#variable "mount_target_id" {}
#variable "log_group_display_name" {}
variable "logdefinition" {}
variable "label_prefix" {}
variable "loggroup" {}
variable "log_retention_duration" {}
variable "log_group_id" {}
variable "log_is_enabled" {}
variable "subnet_id" {}


/*
resource "oci_logging_log" "vcnlog" {
  for_each     = var.target_resources
  depends_on   = [oci_core_subnet.PRD_PUB_LB_NET01, oci_core_subnet.PRD_PUB_WEB_NET01, oci_core_subnet.PRD_PRI_APP_NET01]
  display_name = each.value.log_display_name
  log_group_id = oci_logging_log_group.vcnloggroup.id
  log_type     = each.value.log_type

  configuration {
    source {
      category    = each.value.log_config_source_category
      resource    = each.value.log_config_source_resource
      service     = each.value.log_config_source_service
      source_type = each.value.log_config_source_source_type
    }
    compartment_id = var.compartment_ocid
  }

  is_enabled         = each.value.log_is_enabled
  retention_duration = each.value.log_retention_duration
  defined_tags       = each.value.defined_tags
  freeform_tags      = each.value.freeform_tags
}
*/






resource "oci_logging_log" "vcn_log" {
  for_each = var.logdefinition

  display_name = var.label_prefix == "none" ? each.key : format("%s-%s", var.label_prefix, each.key)
  #display_name = var.label_prefix
  #log_group_id = var.loggroup[each.value.loggroup].id
  log_group_id = var.log_group_id
  log_type     = "SERVICE"
  configuration {
    source {
      category = "all"
      resource = var.vcn_id == "none" ? data.oci_core_subnets.PRD_PUB_WEB_NET01[each.key].subnets.0.id : data.oci_core_subnets.PRD_PRI_LB_NET01[each.key].subnets.0.id
      #resource = var.vcn_id == "none" ? data.oci_core_subnets.PRD_PUB_WEB_NET01.subnets.0.id : data.oci_core_subnets.PRD_PRI_LB_NET01.subnets.0.id
      #resource    = var.subnet_id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
  }

  #is_enabled         = lookup(each.value, "enable", true)
  is_enabled         = var.log_is_enabled
  retention_duration = var.log_retention_duration

}



data "oci_core_subnets" "PRD_PRI_LB_NET01" {

  for_each       = var.logdefinition
  compartment_id = var.compartment_ocid

  display_name = var.label_prefix == "none" ? each.key : format("%s-%s", var.label_prefix, each.key)
  #display_name = var.label_prefix
  state  = "AVAILABLE"
  vcn_id = var.vcn_id
}

data "oci_core_subnets" "PRD_PUB_WEB_NET01" {

  for_each       = var.logdefinition
  compartment_id = var.compartment_ocid

  display_name = var.label_prefix == "none" ? each.key : format("%s-%s", var.label_prefix, each.key)
  #display_name = var.label_prefix
  state = "AVAILABLE"

}


