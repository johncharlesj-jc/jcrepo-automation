# VCN
resource "oci_core_virtual_network" "VCN01" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "AppsVCN"
  compartment_id = var.compartment_ocid
  display_name   = "VCN01"
}

# DHCP Options
resource "oci_core_dhcp_options" "AppsDhcpOptions1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN01.id
  display_name   = "AppsDHCPOptions1"

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
resource "oci_core_internet_gateway" "AppsInternetGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "AppsInternetGateway"
  vcn_id         = oci_core_virtual_network.VCN01.id
}

# Route Table for IGW
resource "oci_core_route_table" "AppsRouteTableViaIGW" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN01.id
  display_name   = "AppsRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.AppsInternetGateway.id
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "AppsNATGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "AppsNATGateway"
  vcn_id         = oci_core_virtual_network.VCN01.id
}

# Route Table for NAT
resource "oci_core_route_table" "AppsRouteTableViaNAT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN01.id
  display_name   = "AppsRouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.AppsNATGateway.id
  }
}

/*
resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = var.label_prefix == "none" ? var.service_gateway_display_name : "${var.label_prefix}-${var.service_gateway_display_name}"

  #freeform_tags = var.freeform_tags
  #defined_tags  = var.defined_tags
  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }

  vcn_id = oci_core_virtual_network.VCN01.id

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

  count = var.create_service_gateway == true ? 1 : 0
}
*/


resource "oci_core_service_gateway" "AppsServiceGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "AppsServiceGateway"
  vcn_id         = oci_core_virtual_network.VCN01.id
  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }

}

# Route Table for SGW
resource "oci_core_route_table" "AppsRouteTableViaSGW" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.VCN01.id
  display_name   = "AppsRouteTableViaSGW"
  route_rules {
    destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.AppsServiceGateway.id
  }
}

/*
resource "oci_core_route_table" "service_gw" {
  compartment_id = var.compartment_ocid
  display_name   = var.label_prefix == "none" ? "service-gw-route" : "${var.label_prefix}-service-gw-route"

  #freeform_tags = var.freeform_tags
  #defined_tags = var.defined_tags

  dynamic "route_rules" {
    # * If Service Gateway is created with the module, automatically creates a rule to handle traffic for "all services" through Service Gateway
    for_each = var.create_service_gateway == true ? [1] : []

    content {
      destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.service_gateway[0].id
      description       = "Terraformed - Auto-generated at Service Gateway creation: All Services in region to Service Gateway"
    }
  }

  vcn_id = oci_core_virtual_network.VCN01.id

  
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
  
  count = var.create_service_gateway == true ? 1 : 0
}
*/


# Security List for HTTP/HTTPS
resource "oci_core_security_list" "AppsWebSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "AppsWebSecurityList"
  vcn_id         = oci_core_virtual_network.VCN01.id

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
  compartment_id = var.compartment_ocid
  display_name   = "AppsSSHSecurityList"
  vcn_id         = oci_core_virtual_network.VCN01.id

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


# SQLNet Security List
resource "oci_core_security_list" "AppsSQLNetSecurityList" {
  compartment_id = var.compartment_ocid
  display_name   = "Apps SQLNet Security List"
  vcn_id         = oci_core_virtual_network.VCN01.id

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

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
}


# LoadBalancer Subnet
resource "oci_core_subnet" "PRD_PUB_LB_NET01" {
  #for_each          = var.vcnflowlogdefinition
  cidr_block        = var.Subnet-CIDR1
  display_name      = "PRD_PUB_LB_NET01"
  dns_label         = "AppsN1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.VCN01.id
  route_table_id    = oci_core_route_table.AppsRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.AppsDhcpOptions1.id
  security_list_ids = [oci_core_security_list.AppsWebSecurityList.id]
}

# WebSubnet Public
resource "oci_core_subnet" "PRD_PUB_WEB_NET01" {
  #for_each          = var.vcnflowlogdefinition
  cidr_block        = var.Subnet-CIDR2
  display_name      = "PRD_PUB_WEB_NET01"
  dns_label         = "AppsN2"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.VCN01.id
  route_table_id    = oci_core_route_table.AppsRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.AppsDhcpOptions1.id
  security_list_ids = [oci_core_security_list.AppsWebSecurityList.id]
}


# WebSubnet (private)
resource "oci_core_subnet" "PRD_PRI_LB_NET01" {
  #for_each                   = var.vcnflowlogdefinition
  cidr_block                 = var.Subnet-CIDR3
  display_name               = "PRD_PRI_LB_NET01"
  dns_label                  = "AppsN3"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.VCN01.id
  route_table_id             = oci_core_route_table.AppsRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.AppsDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.AppsWebSecurityList.id, oci_core_security_list.AppsSSHSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# AppSubnet (private)
resource "oci_core_subnet" "PRD_PRI_APP_NET01" {
  #for_each                   = var.vcnflowlogdefinition
  cidr_block                 = var.Subnet-CIDR4
  display_name               = "PRD_PRI_APP_NET01"
  dns_label                  = "AppsN4"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.VCN01.id
  route_table_id             = oci_core_route_table.AppsRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.AppsDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.AppsWebSecurityList.id, oci_core_security_list.AppsSSHSecurityList.id]
  prohibit_public_ip_on_vnic = true
}




# DBSystem Subnet (private)
resource "oci_core_subnet" "PRD_PRI_DB_NET01" {
  #for_each                   = var.vcnflowlogdefinition
  cidr_block                 = var.Subnet-CIDR5
  display_name               = "PRD_PRI_DB_NET01"
  dns_label                  = "AppsN5"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.VCN01.id
  route_table_id             = oci_core_route_table.AppsRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.AppsDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.AppsSSHSecurityList.id, oci_core_security_list.AppsSQLNetSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

