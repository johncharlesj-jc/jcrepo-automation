# VCN
resource "oci_core_virtual_network" "AAVCN02" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "AAVCN2"
  compartment_id = var.compartment_ocid
  display_name   = "AAVCN02"
}

# DHCP Options
resource "oci_core_dhcp_options" "AADhcp2" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.AAVCN02.id
  display_name   = "AppsDHCP2"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["apps.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "AAInternetGateway2" {
  compartment_id = var.compartment_ocid
  display_name   = "AAInternetGateway2"
  vcn_id         = oci_core_virtual_network.AAVCN02.id
}

# Route Table for IGW
resource "oci_core_route_table" "AARouteTableViaIGW2" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.AAVCN02.id
  display_name   = "AARouteTableViaIGW2"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.AAInternetGateway2.id
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "AANATGateway2" {
  compartment_id = var.compartment_ocid
  display_name   = "AANATGateway2"
  vcn_id         = oci_core_virtual_network.AAVCN02.id
}

# Route Table for NAT
resource "oci_core_route_table" "AARouteTableViaNAT2" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.AAVCN02.id
  display_name   = "AARouteTableViaNAT2"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.AANATGateway2.id
  }
}


resource "oci_core_service_gateway" "AAServiceGateway2" {
  compartment_id = var.compartment_ocid
  display_name   = "AAServiceGateway2"
  vcn_id         = oci_core_virtual_network.AAVCN02.id
  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }

}

# Route Table for SGW
resource "oci_core_route_table" "AARouteTableViaSGW2" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.AAVCN02.id
  display_name   = "AARouteTableViaSGW2"
  route_rules {
    destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.AAServiceGateway2.id
  }
}

# Security List for HTTP/HTTPS
resource "oci_core_security_list" "AAWebSecurityList2" {
  compartment_id = var.compartment_ocid
  display_name   = "AAWebSecurityList2"
  vcn_id         = oci_core_virtual_network.AAVCN02.id

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
resource "oci_core_security_list" "AASSHSecurityList2" {
  compartment_id = var.compartment_ocid
  display_name   = "AASSHSecurityList2"
  vcn_id         = oci_core_virtual_network.AAVCN02.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.bastion_ports
    content {
      protocol = "6"
      #source   = "0.0.0.0/0"
      source = var.VCN-CIDR
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


# SQLNet Security List
resource "oci_core_security_list" "AASQLNetSecurityList2" {
  compartment_id = var.compartment_ocid
  display_name   = "AA SQLNet Security List2"
  vcn_id         = oci_core_virtual_network.AAVCN02.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.sqlnet_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }


  dynamic "ingress_security_rules" {
    for_each = var.sqlnet_ports
    content {
      protocol = "6"
      source   = var.VCN-CIDR
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.sqlnet_ports
    content {
      protocol = "6"
      source   = var.Subnet-CIDR1
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


# LoadBalancer Subnet
resource "oci_core_subnet" "PRD_PUB_LB_NET" {
  #for_each          = var.vcnflowlogdefinition
  cidr_block        = var.Subnet-CIDR1
  display_name      = "PRD_PUB_LB_NET"
  dns_label         = "N1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.AAVCN02.id
  route_table_id    = oci_core_route_table.AARouteTableViaIGW2.id
  dhcp_options_id   = oci_core_dhcp_options.AADhcp2.id
  security_list_ids = [oci_core_security_list.AAWebSecurityList2.id]
}

# DBSystem Subnet (private)
resource "oci_core_subnet" "PRD_PRI_APP_NET" {
  #for_each                   = var.vcnflowlogdefinition
  cidr_block                 = var.Subnet-CIDR2
  display_name               = "PRD_PRI_APP_NET"
  dns_label                  = "N2"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.AAVCN02.id
  route_table_id             = oci_core_route_table.AARouteTableViaNAT2.id
  dhcp_options_id            = oci_core_dhcp_options.AADhcp2.id
  security_list_ids          = [oci_core_security_list.AASSHSecurityList2.id, oci_core_security_list.AASQLNetSecurityList2.id]
  prohibit_public_ip_on_vnic = true
}

# Backup Subnet
resource "oci_core_subnet" "PRD_PRI_BKUP_NET" {
  #for_each                   = var.vcnflowlogdefinition
  cidr_block                 = var.Subnet-CIDR3
  display_name               = "PRD_PRI_BKUP_NET"
  dns_label                  = "N3"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.AAVCN02.id
  route_table_id             = oci_core_route_table.AARouteTableViaNAT2.id
  dhcp_options_id            = oci_core_dhcp_options.AADhcp2.id
  security_list_ids          = [oci_core_security_list.AASSHSecurityList2.id, oci_core_security_list.AASQLNetSecurityList2.id]
  prohibit_public_ip_on_vnic = true
}

