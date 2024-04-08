# DBSystem
resource "oci_database_db_system" "DBAATemp" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  cpu_core_count      = var.CPUCoreCount
  database_edition    = var.DBEdition

  db_system_options {
    storage_management = "LVM"
  }

  backup_configuration {
    auto_backup_enabled = var.backup_enabled
  }

  db_home {
    database {
      admin_password = var.DBAdminPassword
      db_name        = var.DBName
      character_set  = var.CharacterSet
      ncharacter_set = var.NCharacterSet
      db_workload    = var.DBWorkload
      pdb_name       = var.PDBName
    }
    db_version   = var.DBVersion
    display_name = var.DBDisplayName
  }
  shape           = var.DBNodeShape
  subnet_id       = oci_core_subnet.PRD_PRI_APP_NET.id
  ssh_public_keys = [var.password]
  #ssh_public_keys         = ""
  display_name            = var.DBSystemDisplayName
  domain                  = var.DBNodeDomainName
  hostname                = var.DBNodeHostName
  data_storage_percentage = "40"
  data_storage_size_in_gb = var.DataStorageSizeInGB
  license_model           = var.LicenseModel
  node_count              = var.NodeCount
}



