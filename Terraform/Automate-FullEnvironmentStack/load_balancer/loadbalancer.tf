# Public Load Balancer
resource "oci_load_balancer" "AppsLoadBalancer" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = oci_identity_compartment.AppsCompartment.id
  subnet_ids = [
    oci_core_subnet.AppsWebSubnet.id
  ]
  display_name = "AppsLoadBalancer"
}

# LoadBalancer Listener
resource "oci_load_balancer_listener" "AppsLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.AppsLoadBalancer.id
  name                     = "AppsLoadBalancerListener"
  default_backend_set_name = oci_load_balancer_backendset.AppsLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"
}

# LoadBalancer Backendset
resource "oci_load_balancer_backendset" "AppsLoadBalancerBackendset" {
  name             = "AppsLBBackendset"
  load_balancer_id = oci_load_balancer.AppsLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# LoadBalanacer Backend for WebServer1 Instance
resource "oci_load_balancer_backend" "AppsLoadBalancerBackend" {
  load_balancer_id = oci_load_balancer.AppsLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.AppsLoadBalancerBackendset.name
  ip_address       = oci_core_instance.AppsWebserver1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# LoadBalanacer Backend for WebServer2 Instance
resource "oci_load_balancer_backend" "AppsLoadBalancerBackend2" {
  load_balancer_id = oci_load_balancer.AppsLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.AppsLoadBalancerBackendset.name
  ip_address       = oci_core_instance.AppsWebserver2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}


