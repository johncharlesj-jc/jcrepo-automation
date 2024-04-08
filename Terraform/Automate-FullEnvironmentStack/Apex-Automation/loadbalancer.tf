

# Public Load Balancer
resource "oci_load_balancer" "AppsLoadBalancer1" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  #compartment_id = oci_identity_compartment.AppsCompartment.id
  compartment_id = var.compartment_ocid
  subnet_ids = [
    oci_core_subnet.PRD_PUB_LB_NET.id
  ]
  #subnet_id        = oci_core_subnet.PUB_LB_NET.id
  display_name = "AppsLoadBalancer1"
}

#-----------Certificate --------------#

resource "oci_load_balancer_certificate" "star_aacloudapps" {

  #Required
  certificate_name = ""
  load_balancer_id = oci_load_balancer_load_balancer.AppsLoadBalancer1.id

  #Optional
  #private_key        = file(var.ssl_certificate_private_key_path)
  #public_certificate = file(var.ssl_certificate_public_key_path)
  private_key        = file(var.apps_privatekey)
  public_certificate = file(var.apps_csr)
  ca_certificate     = file(var.apps_bundle)
  passphrase         = var.pass

  lifecycle {
    create_before_destroy = true
  }
}

# LoadBalancer Backendset
resource "oci_load_balancer_backendset" "AppsLoadBalancer1Backendset" {
  name             = "AppsLB1Backendset"
  load_balancer_id = oci_load_balancer.AppsLoadBalancer1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "8080"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/i/apex_version.txt"
  }
}

resource "oci_load_balancer_listener" "AppsLoadBalancer1Listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.AppsLoadBalancer1.id
  name                     = "AppsLoadBalancer1Listener"
  default_backend_set_name = oci_load_balancer_backend_set.AppsLoadBalancer1_Backendset01.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_name = oci_load_balancer_certificate.AppsLoadBalancer1.certificate_name
    # trusted_certificate_authority_ids = var.trusted_certificate_authority_ids
    verify_peer_certificate = false
    protocols               = ["TLSv1.1", "TLSv1.2"]
    server_order_preference = "ENABLED"
    cipher_suite_name       = oci_load_balancer_ssl_cipher_suite.AppsLoadBalancer1_ssl_cipher_suite.name
  }
  connection_configuration {
    idle_timeout_in_seconds = "300"
  }
}

resource "oci_load_balancer_backend" "AppsLoadBalancer1_BackendHost" {
  load_balancer_id = oci_load_balancer_load_balancer.AppsLoadBalancer1.id
  backendset_name  = oci_load_balancer_backend_set.AppsLoadBalancer1_Backendset01.name
  #ip_address       = ""
  ip_address = data.oci_core_vnic.DBAATemp_VNIC1.private_ip_address
  port       = "8080"
  backup     = false
  drain      = false
  offline    = false
  weight     = 1
}

resource "oci_load_balancer_ssl_cipher_suite" "AppsLoadBalancer1_ssl_cipher_suite" {
  #Required
  name = "AppsLoadBalancer1_ssl_cipher_suite"

  ciphers = ["", ""]

  #Optional
  load_balancer_id = oci_load_balancer_load_balancer.AppsLoadBalancer1.id
}

resource "oci_load_balancer_rule_set" "AppsLoadBalancer1_http_redirect_rule_set" {
  #Required
  items {
    #Required
    action = "REDIRECT"


    conditions {
      #Required
      attribute_name  = "PATH"
      attribute_value = "/"

      #Optional
      operator = "FORCE_LONGEST_PREFIX_MATCH"
    }


    redirect_uri {

      #Optional
      host     = "{host}"
      path     = "{path}"
      port     = 443
      protocol = "https"
      query    = "{query}"
    }
    response_code = "302"
  }


  load_balancer_id = oci_load_balancer_load_balancer.AppsLoadBalancer1.id
  name             = "Redirect_all_http_to_https"
}

resource "oci_load_balancer_listener" "AppsLoadBalancer1_Redirect_Listener01" {
  load_balancer_id         = oci_load_balancer_load_balancer.AppsLoadBalancer1.id
  name                     = "HTTP_Redirect_Listener01"
  default_backend_set_name = oci_load_balancer_backend_set.AppsLoadBalancer1_Backendset01.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "300"
  }

  rule_set_names = [oci_load_balancer_rule_set.AppsLoadBalancer1_http_redirect_rule_set.name]
}


