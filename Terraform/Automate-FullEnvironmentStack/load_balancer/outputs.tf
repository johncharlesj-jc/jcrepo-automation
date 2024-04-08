# LoadBalancer Public IP
output "AppsLoadBalancer_Public_IP" {
  value = [oci_load_balancer.AppsLoadBalancer.ip_addresses]
}

# WebServer1 Instance Public IP
output "AppsWebserver1PublicIP" {
  value = [data.oci_core_vnic.AppsWebserver1_VNIC1.public_ip_address]
}

# WebServer1 Instance Public IP
output "AppsWebserver2PublicIP" {
  value = [data.oci_core_vnic.AppsWebserver2_VNIC1.public_ip_address]
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

