# VCN
resource "oci_core_virtual_network" "AppsVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "AppsVCN"
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsVCN"
}

# DHCP
resource "oci_core_dhcp_options" "AppsDhcpOptions1" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  vcn_id         = oci_core_virtual_network.AppsVCN.id
  display_name   = "AppsDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["Apps.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "AppsInternetGateway" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsInternetGateway"
  vcn_id         = oci_core_virtual_network.AppsVCN.id
}

# Route Table
resource "oci_core_route_table" "AppsRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  vcn_id         = oci_core_virtual_network.AppsVCN.id
  display_name   = "AppsRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.AppsInternetGateway.id
  }
}

# Security List
resource "oci_core_security_list" "AppsSecurityList" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsSecurityList"
  vcn_id         = oci_core_virtual_network.AppsVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.service_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
}

# Subnet
resource "oci_core_subnet" "AppsWebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "AppsWebSubnet"
  dns_label         = "AppsN1"
  compartment_id    = oci_identity_compartment.AppsCompartment.id
  vcn_id            = oci_core_virtual_network.AppsVCN.id
  route_table_id    = oci_core_route_table.AppsRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.AppsDhcpOptions1.id
  security_list_ids = [oci_core_security_list.AppsSecurityList.id]
}
