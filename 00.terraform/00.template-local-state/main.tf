# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "${var.project_name}-rg-${var.environment}"
  location = var.azure_region
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "${var.project_name}-vnet-${var.environment}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}