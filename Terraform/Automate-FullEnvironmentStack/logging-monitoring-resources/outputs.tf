# Server Instance Public IP
output "Appsserver1PublicIP" {
  value = [data.oci_core_vnic.Appsserver1_VNIC1.public_ip_address]
}

/*
output "vcn_logid" {
  value = { for k, v in oci_logging_log.vcn_flow_log : v.display_name => v.id }
}

output "vcn_loggroupid" {
  value = { for k, v in var.loggroup : v.display_name => v.id }
}
*/


# Generated Private Key for Server Instance
#output "generated_ssh_private_key" {
#  value     = tls_private_key.public_private_key_pair.private_key_pem
#  sensitive = true
#}
