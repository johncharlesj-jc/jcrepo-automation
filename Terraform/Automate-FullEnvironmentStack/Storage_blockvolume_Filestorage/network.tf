# VCN
resource "oci_core_virtual_network" "AppsVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "AppsVCN"
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsVCN"
}

# DHCP
resource "oci_core_dhcp_options" "" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  vcn_id         = oci_core_virtual_network.AppsVCN.id
  display_name   = ""

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = [".com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "AppsInternetGateway" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsInternetGateway"
  vcn_id         = oci_core_virtual_network.AppsVCN.id
}

# Route Table for IGW
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

# NAT Gateway
resource "oci_core_nat_gateway" "AppsNATGateway" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsNATGateway"
  vcn_id         = oci_core_virtual_network.AppsVCN.id
}

# Route Table for NAT
resource "oci_core_route_table" "AppsRouteTableViaNAT" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  vcn_id         = oci_core_virtual_network.AppsVCN.id
  display_name   = "AppsRouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.AppsNATGateway.id
  }
}

# Security List for HTTP/HTTPS
resource "oci_core_security_list" "AppsWebSecurityList" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsWebSecurityList"
  vcn_id         = oci_core_virtual_network.AppsVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
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

# Security List for SSH
resource "oci_core_security_list" "AppsSSHSecurityList" {
  compartment_id = oci_identity_compartment.AppsCompartment.id
  display_name   = "AppsSSHSecurityList"
  vcn_id         = oci_core_virtual_network.AppsVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.bastion_ports
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

# WebSubnet (private)
resource "oci_core_subnet" "AppsWebSubnet" {
  cidr_block                 = var.WebSubnet-CIDR
  display_name               = "AppsWebSubnet"
  dns_label                  = "AppsN2"
  compartment_id             = oci_identity_compartment.AppsCompartment.id
  vcn_id                     = oci_core_virtual_network.AppsVCN.id
  route_table_id             = oci_core_route_table.AppsRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.AppsDhcp.id
  security_list_ids          = [oci_core_security_list.AppsWebSecurityList.id, oci_core_security_list.AppsSSHSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "AppsLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "AppsLBSubnet"
  dns_label         = "AppsN1"
  compartment_id    = oci_identity_compartment.AppsCompartment.id
  vcn_id            = oci_core_virtual_network.AppsVCN.id
  route_table_id    = oci_core_route_table.AppsRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.AppsDhcp.id
  security_list_ids = [oci_core_security_list.AppsWebSecurityList.id]
}

# Bastion Subnet (public)
resource "oci_core_subnet" "AppsBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "AppsBastionSubnet"
  dns_label         = "AppsN3"
  compartment_id    = oci_identity_compartment.AppsCompartment.id
  vcn_id            = oci_core_virtual_network.AppsVCN.id
  route_table_id    = oci_core_route_table.AppsRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.AppsDhcp.id
  security_list_ids = [oci_core_security_list.AppsSSHSecurityList.id]
}




