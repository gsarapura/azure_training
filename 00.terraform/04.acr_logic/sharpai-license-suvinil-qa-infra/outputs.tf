output "resource_group_name" {
  value = azurerm_resource_group.qa-infra-rg.name
}

output "container_registry_name" {
  value = azurerm_container_registry.qa-infra-acr.name
}

output "container_registry_login_server" {
  value = azurerm_container_registry.qa-infra-acr.login_server
}