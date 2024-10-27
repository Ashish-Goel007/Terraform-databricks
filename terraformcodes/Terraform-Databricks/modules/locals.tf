locals {
  default_storage_account_key = azurerm_storage_account.default_storage_account.primary_access_key
  custom_storage_account_key  = azurerm_storage_account.custom_storage_account.primary_access_key

  default_storage_config = {
    "spark.hadoop.fs.azure"                         = "org.apache.hadoop.fs.azure.NativeAzureFileSystem"
    "spark.hadoop.fs.azure.abfss.impl"              = "org.apache.hadoop.fs.azurebfs.AzureBlobFileSystem"
    "spark.databricks.delta.preview.enabled"        = "true",
    "spark.databricks.driverLog.enabled"            = "true",
    "spark.databricks.cluster.log.conf.destination" = "abfss://driverlogs@${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net/",
    "spark.databricks.driverLog.storageAccountName" = azurerm_storage_account.default_storage_account.name,
    #"spark.databricks.driverLog.container"                                          = azurerm_storage_container.default_log_container.name,
    "fs.azure.account.key.${var.default_storage_account_name}.dfs.core.windows.net" = local.default_storage_account_key
  }

  custom_storage_config = {
    "spark.hadoop.fs.azure"                         = "org.apache.hadoop.fs.azure.NativeAzureFileSystem"
    "spark.hadoop.fs.azure.abfss.impl"              = "org.apache.hadoop.fs.azurebfs.AzureBlobFileSystem"
    "spark.databricks.delta.preview.enabled"        = "true",
    "spark.databricks.cluster.log.conf.destination" = "abfss://driverlogs@${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net/",
    "spark.databricks.driverLog.enabled"            = "true",
    "spark.databricks.driverLog.storageAccountName" = azurerm_storage_account.custom_storage_account.name,
    #"spark.databricks.driverLog.container"                                         = azurerm_storage_container.custom_log_container.name,
    "fs.azure.account.key.${var.custom_storage_account_name}.dfs.core.windows.net" = local.custom_storage_account_key
  }

  spark_config = merge(var.default_spark_config,
    local.default_storage_config,
    local.custom_storage_config,
  var.additional_spark_config)

  custom_tags = {
    ProjectName        = var.ProjectName
    CostCenter         = var.CostCenter
    Criticality        = var.Criticality
    BusinessOwnerEmail = var.BusinessOwnerEmail
    DevOwnerEmail      = var.DevOwnerEmail
    ApplicationUID     = var.appuid
    CapexImpact        = var.CapexImpact
    OpexImpact         = var.OpexImpact
  }

}