# WebServer1 Public IP
output "AppsWebserver1PublicIP" {
  value = [data.oci_core_vnic.AppsWebserver1_VNIC1.public_ip_address]
}

# WebServer2 Public IP
output "AppsWebserver2PublicIP" {
  value = [data.oci_core_vnic.AppsWebserver2_VNIC1.public_ip_address]
}

# Private Key for WebServer
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
