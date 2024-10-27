variable "resource_group" {
  type        = string
  description = "RG of Databricks"

}



variable "location" {
  type        = string
  description = "Location of Databricks"

  validation {
    condition     = contains(["centralus", "westeurope", "northeurope"], var.location)
    error_message = "Location is not valid."
  }

}

variable "databricks_token" {
  type        = string
  description = "Token to authenticate to Databricks."
  default     = "test"
}

variable "default_spark_config" {
  type = map(string)
  default = {
    "spark.databricks.delta.preview.enabled"              = "true"
    "spark.sql.session.timeZone"                          = "UTC"
    "spark.sql.shuffle.partitions"                        = "180"
    "spark.databricks.delta.merge.repartitionBeforeWrite" = "true"
  }
}

variable "additional_spark_config" {
  type    = map(string)
  default = {}
}

variable "secret_scope_name" {
  type        = string
  description = "Secret Scope Name"
}

variable "secret_key" {
  type        = string
  description = "Secret Key"
}

variable "secret_value" {
  type        = string
  description = "Secret Value"
}

variable "workspace" {
  type        = string
  description = "Name of Databricks"
}

variable "job_name" {
  type        = string
  description = "Name of the Databricks job."
}

variable "notebook_path" {
  type    = string
  default = "/test"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name for the Databricks job."
}

variable "spark_version" {
  type    = string
  default = "7.3.x-scala2.12"
}

variable "node_type" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "min_workers" {
  type    = number
  default = 1
}

variable "max_workers" {
  type    = number
  default = 10
}

variable "default_storage_account_name" {
  type = string
}

variable "custom_storage_account_name" {
  type = string
}

variable "log_container_name" {
  type = string
}

variable "task_name" {
  type        = string
  description = "Name of the Task"
}

variable "ProjectName" {
  type = string
}

variable "CostCenter" {
  type = string
}

variable "Criticality" {
  type = string
}

variable "BusinessOwnerEmail" {
  type = string
}

variable "DevOwnerEmail" {
  type = string
}

variable "appuid" {
  type = string
}

variable "CapexImpact" {
  type = string
}

variable "OpexImpact" {
  type = string
}

variable "vnet_name" {

}

variable "sku" {
  type = string
}

variable "account_tier" {
  type = string
}