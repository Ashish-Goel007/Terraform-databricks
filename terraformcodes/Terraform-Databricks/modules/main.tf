resource "azurerm_databricks_workspace" "WorkSpace" {
  name                              = var.workspace
  resource_group_name               = azurerm_resource_group.ResourceGroup.name
  location                          = azurerm_resource_group.ResourceGroup.location
  sku                               = var.sku
  managed_resource_group_name       = format("%s-%s", var.workspace, "managed-databricks-rg")
  infrastructure_encryption_enabled = var.sku == "premium" ? true : false

  custom_parameters {
    no_public_ip                                         = true # Databricks workspace does not have a public IP address
    virtual_network_id                                   = azurerm_virtual_network.databricks-vnet.id
    private_subnet_name                                  = azurerm_subnet.pvt-subnet.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private-nsg.id
    public_subnet_name                                   = azurerm_subnet.pub-subnet.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public-nsg.id
  }

  tags = local.custom_tags


}

data "azurerm_client_config" "current" {}

resource "databricks_user" "name" {
  user_name    = "abc@gmail.com"
  display_name = "Admin"
}

resource "databricks_cluster" "cluster" {
  cluster_name            = var.cluster_name
  spark_conf              = local.spark_config
  spark_version           = var.spark_version
  node_type_id            = var.node_type
  autotermination_minutes = 90
  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }
  custom_tags = {
    Department = "DevOps Team"
  }

  /*init_scripts {
    dbfs {
      destination = databricks_dbfs_file.driverlogs_mount_script_default.path
    }
  }

  init_scripts {
    dbfs {
      destination = databricks_dbfs_file.driverlogs_mount_script_custom.path
    }
  }*/
}

resource "databricks_notebook" "my_notebook" {
  content_base64 = base64encode("print('Hello World')")
  language       = "PYTHON"
  path           = var.notebook_path
}


resource "databricks_job" "this" {
  name                = var.job_name # Name of the Job
  max_concurrent_runs = 1
  timeout_seconds     = 3600


  job_cluster {
    job_cluster_key = "j"
    new_cluster {
      spark_conf    = local.spark_config
      num_workers   = 1
      spark_version = var.spark_version
      node_type_id  = var.node_type
    }
  }

  task {
    task_key = var.task_name
    new_cluster {
      num_workers   = 1
      spark_conf    = local.spark_config
      spark_version = var.spark_version
      node_type_id  = var.node_type
    }
    notebook_task {
      notebook_path = var.notebook_path
    }
  }


  email_notifications {
    no_alert_for_skipped_runs = true
  }
}


resource "databricks_secret_scope" "this" {
  name = var.secret_scope_name
}

resource "databricks_secret" "dbfs" {
  scope        = databricks_secret_scope.this.name
  key          = var.secret_key
  string_value = var.secret_value
}

resource "databricks_dbfs_file" "driverlogs_mount_script_default" {
  content_base64 = base64encode(<<EOT
dbutils.fs.mount(
  source = "abfss://driverlogs@${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net/",
  mount_point = "/mnt/driverlogs",
  extra_configs = {
    "fs.azure.account.key.${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net": dbutils.secrets.get(scope = "my_scope", key = "my_key"),
    "fs.azure.account.auth.type.${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net": "OAuth",
    "fs.azure.account.oauth.provider.type.${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id.${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net": "${azurerm_user_assigned_identity.databricks_identity.client_id}",
    "fs.azure.account.oauth2.client.secret.${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net": dbutils.secrets.get(scope = "my_scope", key = "my_secret"),
    "fs.azure.account.oauth2.client.endpoint.${azurerm_storage_account.default_storage_account.name}.dfs.core.windows.net": "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/token"
  }
)
EOT
  )
  path = "/mnt/driverlogs/default/init_script.sh"
}

resource "databricks_dbfs_file" "driverlogs_mount_script_custom" {
  content_base64 = base64encode(<<EOT
dbutils.fs.mount(
  source = "abfss://driverlogs@${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net/",
  mount_point = "/mnt/driverlogs",
  extra_configs = {
    "fs.azure.account.key.${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net": dbutils.secrets.get(scope = "my_scope", key = "my_key"),
    "fs.azure.account.auth.type.${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net": "OAuth",
    "fs.azure.account.oauth.provider.type.${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id.${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net": "${azurerm_user_assigned_identity.databricks_identity.client_id}",
    "fs.azure.account.oauth2.client.secret.${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net": dbutils.secrets.get(scope = "my_scope", key = "my_secret"),
    "fs.azure.account.oauth2.client.endpoint.${azurerm_storage_account.custom_storage_account.name}.dfs.core.windows.net": "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/token"
  }
)
EOT
  )
  path = "/mnt/driverlogs/default/init_script.sh"
}

resource "azurerm_user_assigned_identity" "databricks_identity" {
  name                = "databricks-identity"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location

  tags = local.custom_tags
}