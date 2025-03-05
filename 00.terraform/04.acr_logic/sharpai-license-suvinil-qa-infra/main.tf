resource "azurerm_resource_group" "qa-infra-rg" {
  name     = "${var.project_name}-${var.environment}"
  location = var.azure_region
  tags = {
    environment = var.environment
  }
}

resource "azurerm_container_registry" "qa-infra-acr" {
  name                = "${lower(replace(var.project_name, "-", ""))}acr" # Ensure lowercase and no leading/trailing hyphens
  resource_group_name = azurerm_resource_group.qa-infra-rg.name
  location            = azurerm_resource_group.qa-infra-rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags = {
    environment = var.environment
  }
}

resource "null_resource" "check_load_mock_image" {
  provisioner "local-exec" {
    command = <<EOT
      RESULT=$(./scripts/az-acr.bash check-mock-image --acr ${azurerm_container_registry.qa-infra-acr.name} \
                        --server ${azurerm_container_registry.qa-infra-acr.login_server} \
                        --image ${var.mock_acr_image_name} \
                        --tag ${var.mock_acr_tag_name})
      if ! $RESULT ; then
          ./scripts/az-acr.bash create-mock-image --acr ${azurerm_container_registry.qa-infra-acr.name} \
                        --server ${azurerm_container_registry.qa-infra-acr.login_server} \
                        --image ${var.mock_acr_image_name} \
                        --tag ${var.mock_acr_tag_name}
      fi
      # Sleep for a few seconds to allow the image to be fully available
      sleep 10
    EOT
  }
  # Ensure this resource runs before the container app job
  depends_on = [azurerm_container_registry.qa-infra-acr]
}

resource "azurerm_log_analytics_workspace" "qa-infra-law" {
  name                = "${var.project_name}-log-analytics-workspace"
  location            = azurerm_resource_group.qa-infra-rg.location
  resource_group_name = azurerm_resource_group.qa-infra-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = var.environment
  }
}

resource "azurerm_container_app_environment" "qa-infra-app-env" {
  name                       = "${var.project_name}-app-environment"
  location                   = azurerm_resource_group.qa-infra-rg.location
  resource_group_name        = azurerm_resource_group.qa-infra-rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.qa-infra-law.id
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_user_assigned_identity" "acr_pull_user" {
  location            = azurerm_resource_group.qa-infra-rg.location
  name                = "${var.project_name}-acr-pull-user"
  resource_group_name = azurerm_resource_group.qa-infra-rg.name
  tags = {
    environment = var.environment
  }
}

resource "azurerm_role_assignment" "acr_pull_assignment" {
  scope                = azurerm_container_registry.qa-infra-acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull_user.principal_id
}

resource "azurerm_container_app_job" "qa-infra-app-job" {
  name                         = "${var.project_name}-app-job"
  location                     = azurerm_resource_group.qa-infra-rg.location
  resource_group_name          = azurerm_resource_group.qa-infra-rg.name
  container_app_environment_id = azurerm_container_app_environment.qa-infra-app-env.id

  replica_timeout_in_seconds = 6000
  replica_retry_limit        = 1
  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.acr_pull_user.id ]
  }

  registry {
    identity = azurerm_user_assigned_identity.acr_pull_user.id
    server = azurerm_container_registry.qa-infra-acr.login_server
  }

  template {
    container {
      image = "${azurerm_container_registry.qa-infra-acr.login_server}/${var.mock_acr_image_name}:${var.mock_acr_tag_name}"
      name  = "testcontainerappsjob0"
      readiness_probe {
        transport = "HTTP"
        port      = 5000
      }

      liveness_probe {
        transport = "HTTP"
        port      = 5000
        path      = "/health"

        header {
          name  = "Cache-Control"
          value = "no-cache"
        }

        initial_delay           = 5
        interval_seconds        = 20
        timeout                 = 2
        failure_count_threshold = 1
      }
      startup_probe {
        transport = "TCP"
        port      = 5000
      }

      cpu    = 4
      memory = "8Gi"
    }
  }

  tags = {
    environment = var.environment
  }
}

# resource "azurerm_storage_account" "qixample" {
#   name                     = "storageaccountname"
#   resource_group_name      = azurerm_resource_group.example.name
#   location                 = azurerm_resource_group.example.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = var.environment
#   }
# }