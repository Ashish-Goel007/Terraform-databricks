# Terraform Block
terraform {
  #required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = ">= 2.0" 
    }
    databricks = {
      source  = "databricks/databricks"
      version = " 1.0.0"
    }
  }
}

# Provider Block
provider "azurerm" {
  features {}

  subscription_id = "ff9eefe4-311a-4e21-94b8-b9739e8d7da2"
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.WorkSpace.id
}