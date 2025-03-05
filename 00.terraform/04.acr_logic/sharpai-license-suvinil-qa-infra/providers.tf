terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "suvinil-tfstates"
    storage_account_name = "tfstatestorage17189"
    container_name       = "regression-tests-tfstate"
    key                  = "terraform.tfstate.regression.tests"
  }
}

provider "azurerm" {
  features {}
}
