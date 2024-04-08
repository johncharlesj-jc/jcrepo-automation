/*
# Server Instance Private IP
output "TestServer1PrivateIP" {
  value = [data.oci_core_vnic.TestServer1_VNIC1.public_ip_address]
}
*/


# Generated Private Key for Server Instance
#output "generated_ssh_private_key" {
#  value     = tls_private_key.public_private_key_pair.private_key_pem
#  sensitive = true
#}

output "instance_private_and_public_ips" {
  value = {
    for instance in module.CreateInstances.instances :
    instance.private_ip => instance.public_ip
  }
}
