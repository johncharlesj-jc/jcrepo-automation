# Mount Target

resource "oci_file_storage_mount_target" "AppsMountTarget" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.AppsCompartment.id
  subnet_id           = oci_core_subnet.AppsWebSubnet.id
  ip_address          = var.MountTargetIPAddress
  display_name        = ""
}

# Exportset

resource "oci_file_storage_export_set" "AppsExportset" {
  mount_target_id = oci_file_storage_mount_target.AppsMountTarget.id
  display_name    = ""
}

# FileSystem

resource "oci_file_storage_file_system" "AppsFilesystem" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.AppsCompartment.id
  display_name        = ""
}

# Export

resource "oci_file_storage_export" "AppsExport" {
  export_set_id  = oci_file_storage_mount_target.AppsMountTarget.export_set_id
  file_system_id = oci_file_storage_file_system.AppsFilesystem.id
  path           = "/fs"
}

