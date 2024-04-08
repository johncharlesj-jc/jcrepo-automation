
/*
resource "oci_logging_log" "vcn_flow_log" {
  #for_each = var.vcnflowlogdefinition

  #display_name = each.key
  #display_name = var.label_prefix == "none" ? each.key : format("%s-%s", var.label_prefix, each.key)
  #compartment_id = var.compartment_ocid
  display_name = var.log_display_name
  log_group_id = oci_logging_log_group.vcnloggroup.id
  #log_group_id = var.vcnloggroup[each.value.vcnloggroup].id
  log_type = var.log_log_type

  configuration {
    source {
      category    = "all"
      resource    = "ocid1.subnet.oc1.iad.aaaaaaaaz4sm7ju3oeqvv24nu4edoaaxelpe3sowcc6f7s5kqvq2wojplcha"
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
  }



  #is_enabled         = lookup(each.value, "enable", true)
  #is_enabled         = var.log_is_enabled
  #retention_duration = var.vcnflowlog_retention_duration

}
*/


#VCN loggroup resource
resource "oci_logging_log_group" "vcnloggroup" {

  #for_each = toset(local.vcnloggroup)

  compartment_id = var.compartment_ocid
  description    = "VCN flowlogs Loggroup"
  display_name   = var.log_group_display_name
  #display_name   = var.label_prefix == "none" ? each.value : format("%s-%s", var.label_prefix, each.value)
  #freeform_tags  = var.loggroup_tags
  #vcnloggroup = oci_logging_log_group.vcnloggroup

}


locals {
  vcnloggroup = var.vcnloggroup
  #vcnloggroup = [for k, v in var.service_logdef : v.vcnloggroup if v.service == "testvcnflowlog"]
  logdefinition = var.logdefinition
}

module "vcnlog" {
  source                 = "./vcnlog"
  compartment_ocid       = var.compartment_ocid
  label_prefix           = var.label_prefix
  logdefinition          = var.logdefinition
  log_retention_duration = var.log_retention_duration
  loggroup               = oci_logging_log_group.vcnloggroup
  log_group_id           = oci_logging_log_group.vcnloggroup.id
  vcn_id                 = oci_core_virtual_network.VCN01.id
  log_is_enabled         = var.log_is_enabled
  subnet_id              = var.subnet_id

  count = length(var.logdefinition) >= 1 ? 1 : 0

}






/*
# loggroup resource
resource "oci_logging_log_group" "loggroup" {

  for_each = toset(local.loggroup)

  compartment_id = var.compartment_ocid
  description    = "VCN Loggroup"
  display_name   = each.value
  #freeform_tags  = var.loggroup_tags

}
*/

/*
locals {

  vcnflowlogdefinition = { for k, v in var.service_logdef : k => v if v.service == "testvcnflowlog" }
  loggroup             = [for k, v in var.service_logdef : v.loggroup if v.service == "testvcnflowlog"]
}
*/


/*
resource "oci_logging_log_group" "analyticscloudloggroup" {

  for_each = toset(local.analyticscloudloggroup)

  compartment_id = var.compartment_id
  description    = "Oracle Analytics Cloud Loggroup"
  display_name   = var.label_prefix == "none" ? each.value : format("%s-%s", var.label_prefix, each.value)
  freeform_tags  = var.loggroup_tags

}
*/

/*
resource "oci_logging_log" "vcn_log" {
  for_each = var.vcnflowlogdefinition

  display_name = var.label_prefix == "none" ? each.key : format("%s-%s", var.label_prefix, each.key)
  log_group_id = oci_logging_log_group.vcnloggroup.id
  log_type     = "SERVICE"
  configuration {
    source {
      category = "all"
      resource = oci_core_virtual_network.VCN01.id == "none" ? data.oci_core_subnets.PRD_PUB_WEB_NET01[each.key].subnets.0.id : data.oci_core_subnets.PRD_PUB_LB_NET01[each.key].subnets.0.id
      #resource    = oci_core_subnet.PRD_PUB_WEB_NET01.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
  }

  is_enabled         = lookup(each.value, "enable", true)
  retention_duration = var.vcnflowlog_retention_duration

}

data "oci_core_subnets" "PRD_PUB_WEB_NET01" {

  for_each       = var.vcnflowlogdefinition
  compartment_id = var.compartment_ocid

  display_name = each.value.resource
  state        = "AVAILABLE"
  vcn_id       = oci_core_virtual_network.VCN01.id
}

data "oci_core_subnets" "PRD_PUB_LB_NET01" {

  for_each       = var.vcnflowlogdefinition
  compartment_id = var.compartment_ocid

  display_name = each.value.resource
  state        = "AVAILABLE"

}
*/

/*
##OCI LZ

resource "oci_logging_log" "vcnlog" {
  #for_each     = var.target_resources
  display_name = var.log_display_name
  log_group_id = oci_logging_log_group.vcnloggroup.id
  log_type     = "SERVICE"
  depends_on   = [oci_core_subnet.PRD_PUB_WEB_NET01, oci_core_subnet.PRD_PRI_DB_NET01]
  #target_resources = local.flow_logs

  
  configuration {
    source {
      category    = each.value.log_config_source_category
      resource    = each.value.log_config_source_resource
      service     = each.value.log_config_source_service
      source_type = each.value.log_config_source_source_type
    }
    compartment_id = var.compartment_ocid
  }
  


  #is_enabled         = each.value.log_is_enabled
  #retention_duration = each.value.log_retention_duration
  #defined_tags       = each.value.defined_tags
  #freeform_tags      = each.value.freeform_tags
}

locals {
  all_subnets      = merge(PRD_PUB_WEB_NET01.subnets, PRD_PRI_DB_NET01.subnets)
  target_resources = local.flow_logs
  depends_on       = [oci_core_subnet.PRD_PUB_WEB_NET01, oci_core_subnet.PRD_PRI_DB_NET01]

  flow_logs = { for k, v in local.all_subnets : k =>
    {
      log_display_name              = "${k}-flow-log",
      log_type                      = "SERVICE",
      log_config_source_resource    = v.id,
      log_config_source_category    = "all",
      log_config_source_service     = "flowlogs",
      log_config_source_source_type = "OCISERVICE",
      #log_config_compartment        = module.lz_compartments.compartments[local.security_compartment.key].id,
      compartment_id         = var.compartment_ocid
      log_is_enabled         = true,
      log_retention_duration = 30,
      #defined_tags                  = null,
      #freeform_tags                 = null
      depends_on = [oci_core_subnet.PRD_PUB_WEB_NET01, oci_core_subnet.PRD_PRI_DB_NET01]
    }
  }
}
*/



/*
locals {
  all_subnets = merge(module.PRD_PUB_LB_NET01.subnets, module.PRD_PUB_WEB_NET01.subnets, module.PRD_PRI_APP_NET01.subnets)

  flow_logs = { for k, v in local.all_subnets : k =>
    {
      log_display_name              = "${k}-flow-log",
      log_type                      = "SERVICE",
      log_config_source_resource    = v.id,
      log_config_source_category    = "all",
      log_config_source_service     = "flowlogs",
      log_config_source_source_type = "OCISERVICE",
      log_config_compartment        = var.compartment_ocid,
      log_is_enabled                = true,
      log_retention_duration        = 30,
      defined_tags                  = null,
      freeform_tags                 = null
    }
  }
}
*/

