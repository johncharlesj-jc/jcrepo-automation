# Home Region Subscription DataSource
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


# Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "Apextemp-BH_VNIC1_attach" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.Apextemp-BH.id
}

# Compute VNIC DataSource
data "oci_core_vnic" "Apextemp-BH_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.Apextemp-BH_VNIC1_attach.vnic_attachments.0.vnic_id
}



/*
# DBNodes DataSource
data "oci_database_db_nodes" "DBNodeList" {
  #compartment_id = oci_identity_compartment.Compartment.id
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.APPSDB.id
}

# DBNodes Details DataSource
data "oci_database_db_node" "DBNodeDetails" {
  db_node_id = lookup(data.oci_database_db_nodes.DBNodeList.db_nodes[0], "id")
}

# DBNodes Details VNIC DataSource
data "oci_core_vnic" "APPSDB_VNIC1" {
  vnic_id = data.oci_database_db_node.DBNodeDetails.vnic_id
}
*/


data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
  count = var.create_service_gateway == true ? 1 : 0
}

# DBNodes DataSource
data "oci_database_db_nodes" "DBNodeList" {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.DBAATemp.id
}

# DBNodes Details DataSource
data "oci_database_db_node" "DBNodeDetails" {
  db_node_id = lookup(data.oci_database_db_nodes.DBNodeList.db_nodes[0], "id")
}

# DBNodes Details VNIC DataSource
data "oci_core_vnic" "DBAATemp_VNIC1" {
  vnic_id = data.oci_database_db_node.DBNodeDetails.vnic_id
}
