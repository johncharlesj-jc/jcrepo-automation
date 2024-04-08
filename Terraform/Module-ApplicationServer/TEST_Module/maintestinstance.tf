terraform {
  required_version = ">= 0.15.0"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "= 4.120.0"
    }
  }
}
# General Provider 
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Home Region Provider
provider "oci" {
  alias                = "homeregion"
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  region               = data.oci_identity_region_subscriptions.home_region_subscriptions.region_subscriptions[0].region_name
  disable_auto_retries = "true"
}

# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# ADs DataSource

data "oci_identity_availability_domains" "GetAds" {
  compartment_id = var.tenancy_ocid
}

/*
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}
*/

# Images DataSource
data "oci_core_images" "OSImage" {
  compartment_id = var.compartment_ocid
  #operating_system         = var.instance_os
  #operating_system_version = var.linux_os_version
  shape = var.shape_name

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

## Datasource for webpp backup policy 
data "oci_core_volume_backup_policies" "test_block_volume_backup_policies" {
  filter {
    name   = "display_name"
    values = ["gold"]
  }
}



# Create instances 

module "CreateInstances" {
  source = "../TEST"
  #compartment_id              = module.CreateCompartment.compartment.id
  compartment_ocid             = var.compartment_ocid
  region                       = var.region
  instance_availability_domain = lookup(data.oci_identity_availability_domains.GetAds.availability_domains[1], "name")
  #availablity_domain_name2     = lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name")
  #availablity_domain_name3    = var.availablity_domain_name3
  subnet_id                   = var.subnet_id
  instance_image_ocid         = var.instance_image_ocid
  shape_name                  = var.shape_name
  instance_flex_ocpus         = var.instance_flex_ocpus
  instance_flex_memory_in_gbs = var.instance_flex_memory_in_gbs
  #ssh_public_key               = var.ssh_public_key
  #assign_public_ip             = var.assign_public_ip



  instance_create_vnic_details_hostname_label         = var.instance_create_vnic_details_hostname_label
  instance_create_vnic_details_skip_source_dest_check = var.instance_create_vnic_details_skip_source_dest_check

  instance_variables          = var.instance_variables
  MountTargetIPAddress        = var.MountTargetIPAddress
  ssh_key_private             = var.ssh_key_private
  blockvolume_variables       = var.blockvolume_variables
  boot_volume_size_in_gbs     = var.boot_volume_size_in_gbs
  blockvolume_size            = var.blockvolume_size
  volume_is_auto_tune_enabled = var.volume_is_auto_tune_enabled
}
