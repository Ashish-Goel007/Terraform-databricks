resource "azurerm_log_analytics_workspace" "mylaw" {
  name                = "my-log-workspace"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  sku                 = "PerGB2018"
  retention_in_days   = 100 # Set retention to 100 days
  tags                = local.custom_tags
}

resource "azurerm_monitor_diagnostic_setting" "databricks_diagnostic" {
  name                       = "databricks-to-log-analytics"
  target_resource_id         = azurerm_databricks_workspace.WorkSpace.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.mylaw.id

  enabled_log {
    category = "jobs" # Jobs logs
  }
}