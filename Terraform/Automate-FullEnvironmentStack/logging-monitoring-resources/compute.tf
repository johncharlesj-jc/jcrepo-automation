#Compute

resource "oci_core_instance" "Appsserver1" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  #compartment_id      = oci_identity_compartment.AppsCompartment.id
  compartment_id = var.compartment_ocid
  display_name   = "AppsServer1"
  shape          = var.Shape

  metadata = {
    ssh_authorized_keys = file("/home/opc/.ssh/id_rsa.pub")
  }
  preserve_boot_volume = false

  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }

  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }

  #metadata = {
  #    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  #  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.PRD_PUB_WEB_NET01.id
    assign_public_ip = true
  }
}


