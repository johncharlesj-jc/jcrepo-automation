resource "oci_identity_compartment" "AppsCompartment" {
  provider = oci.homeregion
  name = "AppsCompartment"
  description = "Apps Compartment"
  compartment_id = var.compartment_ocid
  
  provisioner "local-exec" {
    command = "sleep 60"
  }
}
