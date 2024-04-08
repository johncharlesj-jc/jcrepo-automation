#Block Volume
resource "oci_core_volume" "AppsWebserver1BlockVolume" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.AppsCompartment.id
  display_name        = "AppsWebserver1 BlockVolume"
  size_in_gbs         = var.volume_size_in_gbs
}

# Attachment of Block Volume to Webserver1
resource "oci_core_volume_attachment" "AppsWebserver1BlockVolume_attach" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.AppsWebserver1.id
  volume_id       = oci_core_volume.AppsWebserver1BlockVolume.id
}

