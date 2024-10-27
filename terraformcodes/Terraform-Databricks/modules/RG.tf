resource "azurerm_resource_group" "ResourceGroup" {
  name     = var.resource_group
  location = var.location

  tags = local.custom_tags

}