/*resource "oci_identity_compartment" "OCI-CSP-AUDIT" {
  provider       = oci.homeregion
  name           = "OCI-CSP-AUDIT"
  description    = "Apps Compartment"
  compartment_id = var.compartment_ocid

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
*/
