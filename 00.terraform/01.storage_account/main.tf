terraform {
  required_version = ">=0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "learn-50e107c3-741e-48ad-a0c2-f471225d7663"
}

resource "azurerm_storage_account" "example" {
  name                     = substr(md5(data.azurerm_resource_group.rg.id), 0, 24)
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
}

output "id" {
  value = data.azurerm_resource_group.rg.id
}
