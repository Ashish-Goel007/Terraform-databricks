resource "azurerm_virtual_network" "databricks-vnet" {
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.ResourceGroup.location
  name                = format("%s-databricks-VNET", var.vnet_name)
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  tags                = local.custom_tags
}

resource "azurerm_subnet" "pvt-subnet" {
  name                 = "Private-Subnet"
  resource_group_name  = azurerm_resource_group.ResourceGroup.name
  virtual_network_name = azurerm_virtual_network.databricks-vnet.name
  address_prefixes     = ["10.0.0.0/25"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "pvt-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "private-nsg" {
  location            = azurerm_resource_group.ResourceGroup.location
  name                = "Private-Subnet-NSG"
  resource_group_name = azurerm_resource_group.ResourceGroup.name

  tags = local.custom_tags
}

resource "azurerm_subnet_network_security_group_association" "private-nsg" {
  network_security_group_id = azurerm_network_security_group.private-nsg.id
  subnet_id                 = azurerm_subnet.pvt-subnet.id
}

resource "azurerm_subnet" "pub-subnet" {
  name                 = "Public-Subnet"
  resource_group_name  = azurerm_resource_group.ResourceGroup.name
  virtual_network_name = azurerm_virtual_network.databricks-vnet.name
  address_prefixes     = ["10.0.0.128/26"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "pub-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "public-nsg" {
  location            = azurerm_resource_group.ResourceGroup.location
  name                = "Public-Subnet-NSG"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  tags                = local.custom_tags
}

resource "azurerm_subnet_network_security_group_association" "public-nsg" {
  network_security_group_id = azurerm_network_security_group.public-nsg.id
  subnet_id                 = azurerm_subnet.pub-subnet.id
}