resource "azurerm_storage_account" "default_storage_account" {
  name                     = var.default_storage_account_name
  resource_group_name      = azurerm_resource_group.ResourceGroup.name
  location                 = azurerm_resource_group.ResourceGroup.location
  account_replication_type = "LRS"
  account_tier             = var.account_tier
  #public_network_access_enabled = false
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  tags                              = local.custom_tags
  infrastructure_encryption_enabled = var.account_tier == "Standard" ? true : false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.pub-subnet.id, azurerm_subnet.pvt-subnet.id]
  }

  depends_on = [azurerm_subnet.pub-subnet, azurerm_subnet.pvt-subnet]
}

resource "azurerm_storage_account" "custom_storage_account" {
  name                     = var.custom_storage_account_name
  resource_group_name      = azurerm_resource_group.ResourceGroup.name
  location                 = azurerm_resource_group.ResourceGroup.location
  account_replication_type = "LRS"
  account_tier             = var.account_tier
  #public_network_access_enabled = true
  allow_nested_items_to_be_public   = false
  https_traffic_only_enabled        = true
  tags                              = local.custom_tags
  infrastructure_encryption_enabled = var.account_tier == "Standard" ? true : false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.pub-subnet.id, azurerm_subnet.pvt-subnet.id]
  }

  depends_on = [azurerm_subnet.pub-subnet, azurerm_subnet.pvt-subnet]
}


resource "azurerm_storage_container" "default_log_container" {
  name                  = "driverlogs"
  storage_account_name  = azurerm_storage_account.default_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "custom_log_container" {
  name                  = "driverlogs"
  storage_account_name  = azurerm_storage_account.custom_storage_account.name
  container_access_type = "private"
}


resource "azurerm_role_assignment" "default_storage_account_role" {
  scope                = azurerm_storage_account.default_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.databricks_identity.principal_id
}

resource "azurerm_role_assignment" "custom_storage_account_role" {
  scope                = azurerm_storage_account.custom_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.databricks_identity.principal_id
}