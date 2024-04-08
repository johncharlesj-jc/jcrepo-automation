# Bastion Public IP
output "AppsBastionServer_PublicIP" {
  value = [data.oci_core_vnic.AppsBastionServer_VNIC1.public_ip_address]
}

# LoadBalancer URL
output "AppsPublicLoadBalancer_URL" {
  value = ""
}

# WebServer1 Private IP
output "AppsWebserver1PrivateIP" {
  value = [data.oci_core_vnic.AppsWebserver1_VNIC1.private_ip_address]
}

# WebServer2 Private IP
output "AppsWebserver2PrivateIP" {
  value = [data.oci_core_vnic.AppsWebserver2_VNIC1.private_ip_address]
}

# Private Key for WebServer
output "generated_ssh_private_key" {
  value     = tls_private_key.key_pair.private_key_pem
  sensitive = true
}
