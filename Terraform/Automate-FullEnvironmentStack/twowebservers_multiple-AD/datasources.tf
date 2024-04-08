# Home Region DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# ADs DataSource
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Images DataSource
data "oci_core_images" "OSImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# WebServer1 VNIC Attachment DataSource
data "oci_core_vnic_attachments" "AppsWebserver1_VNIC1_attach" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.AppsCompartment.id
  instance_id         = oci_core_instance.AppsWebserver1.id
}

# WebServer1 VNIC DataSource
data "oci_core_vnic" "AppsWebserver1_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.AppsWebserver1_VNIC1_attach.vnic_attachments.0.vnic_id
}

# WebServer2 VNIC Attachment DataSource
data "oci_core_vnic_attachments" "AppsWebserver2_VNIC1_attach" {
  availability_domain = var.availablity_domain_name2 == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name") : var.availablity_domain_name2
  compartment_id      = oci_identity_compartment.AppsCompartment.id
  instance_id         = oci_core_instance.AppsWebserver2.id
}

# WebServer2 VNIC DataSource
data "oci_core_vnic" "AppsWebserver2_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.AppsWebserver2_VNIC1_attach.vnic_attachments.0.vnic_id
}

