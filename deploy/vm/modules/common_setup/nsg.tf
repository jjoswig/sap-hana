resource "azurerm_network_security_group" "sap_nsg" {
  count               = var.use_existing_nsg ? 0 : 1
  name                = local.new_nsg_name
  resource_group_name = azurerm_resource_group.hana-resource-group.name
  location            = azurerm_resource_group.hana-resource-group.location

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "open-hana-db-ports"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3${var.sap_instancenum}00-3${var.sap_instancenum}99"
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sapinst-web-gui"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4237"
    #source_address_prefixes    = ["${chomp(data.http.myip.body)}/32"]
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sapinst-web-gui_local"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4237"
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sapwebdisp-and-sapgw-1"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sap_instancenum < 10 ? "3200-320${var.sap_instancenum+1}" : "3200-32${var.sap_instancenum+1}"
    #source_address_prefixes    = ["${chomp(data.http.myip.body)}/32"]
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sapwebdisp-and-sapgw-2"
    priority                   = 121
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sap_instancenum < 10 ? "3300-330${var.sap_instancenum+1}" : "3300-33${var.sap_instancenum+1}"
    #source_address_prefixes    = ["${chomp(data.http.myip.body)}/32"]
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sapwebdisp-and-sapgw-3"
    priority                   = 122
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sap_instancenum < 10 ? "4700-470${var.sap_instancenum+1}" : "4700-47${var.sap_instancenum+1}"
    #source_address_prefixes    = ["${chomp(data.http.myip.body)}/32"]
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sapwebdisp-and-sapgw-4"
    priority                   = 123
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sap_instancenum < 10 ? "4800-480${var.sap_instancenum+1}" : "4800-48${var.sap_instancenum+1}"
    #source_address_prefixes    = ["${chomp(data.http.myip.body)}/32"]
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "sap-message-server-port"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.sap_instancenum < 10 ? "3600-360${var.sap_instancenum+1}" : "3600-36${var.sap_instancenum+1}"
    source_address_prefixes    = var.allow_ips
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "SUM"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1129"
    source_address_prefixes    = ["${chomp(data.http.myip.body)}/32"]
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_rule" "hana-xsc-rules" {
  count                       = var.use_existing_nsg ? 0 : var.install_xsa ? 0 : length(local.hana_xsc_rules)
  name                        = element(split(",", local.hana_xsc_rules[count.index]), 0)
  priority                    = element(split(",", local.hana_xsc_rules[count.index]), 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = element(split(",", local.hana_xsc_rules[count.index]), 2)
  source_address_prefixes     = local.all_ips
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hana-resource-group.name
  network_security_group_name = azurerm_network_security_group.sap_nsg[0].name
}

resource "azurerm_network_security_rule" "hana-xsa-rules" {
  count                       = var.use_existing_nsg ? 0 : var.install_xsa ? length(local.hana_xsa_rules) : 0
  name                        = element(split(",", local.hana_xsa_rules[count.index]), 0)
  priority                    = element(split(",", local.hana_xsa_rules[count.index]), 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = element(split(",", local.hana_xsa_rules[count.index]), 2)
  source_address_prefixes     = local.all_ips
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.hana-resource-group.name
  network_security_group_name = azurerm_network_security_group.sap_nsg[0].name
}

data "azurerm_network_security_group" "nsg_info" {
  name = element(
    concat(
      azurerm_network_security_group.sap_nsg.*.name,
      [var.existing_nsg_name],
    ),
    0,
  )
  resource_group_name = var.use_existing_nsg ? var.existing_nsg_rg : azurerm_resource_group.hana-resource-group.name
}

