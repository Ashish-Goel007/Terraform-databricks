module "databricks_job" {
  source           = "./modules/"
  resource_group   = "my-test-rg"
  location         = "centralus"
  job_name         = "my-first-job" # Name of the Job
  task_name        = "Task1"        # Name of the Task under a job
  cluster_name     = "mydbspark"    # Name of the Cluster
  spark_version    = "15.4.x-photon-scala2.12"
  node_type        = "Standard_DS3_v2"
  min_workers      = 1
  max_workers      = 1
  workspace        = "my-databricks-workspace"
  databricks_token = "test"
  sku              = "premium"

  # Additional Spark configurations
  additional_spark_config = {
    "spark.sql.shuffle.partitions" = "200"
    "spark.executor.memory"        = "1g"
    "spark.driver.memory"          = "500m"
  }

  default_storage_account_name = "mydefaultstr6712" # Default Storage account
  custom_storage_account_name  = "mycustomstr9012"  # Custom Storage Account
  log_container_name           = "databrickslogs"
  account_tier                 = "Standard"

  secret_scope_name = "db-scope" # Secret Scope
  secret_key        = "db-password"
  secret_value      = "p@$$word@123"
  

  Criticality        = "Low"
  DevOwnerEmail      = ""
  BusinessOwnerEmail = ""
  ProjectName        = ""
  CostCenter         = "11951609"
  appuid             = ""
  CapexImpact        = ""
  OpexImpact         = ""

  vnet_name = "myvnet"
}