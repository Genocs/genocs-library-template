# Create App Services for each environment (Web API)
resource "azurerm_linux_web_app" "web_app" {
  for_each = toset(local.environments)

  name                = "webapi-${local.project_name}-${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  service_plan_id     = azurerm_service_plan.app_service_plan[each.key].id

  site_config {
    application_stack {
      docker_image_name = "${azurerm_container_registry.acr.login_server}/webapi:${each.key == "prod" ? "latest" : each.key}"
    }

    always_on = true
  }

  # Configure container-specific settings
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"    = "false"
    "DOCKER_ENABLE_CI"                       = "true"
    "ASPNETCORE_ENVIRONMENT"                 = each.key
    "DOTNET_ENVIRONMENT"                     = each.key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.app_insights[each.key].connection_string
    "APPLICATIONINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights[each.key].instrumentation_key
  }

  # Assign the user-assigned identity to the App Service
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity[each.key].id]
  }

  # Configure Key Vault access for secrets
  key_vault_reference_identity_id = azurerm_user_assigned_identity.app_identity[each.key].id

  tags = merge(local.tags, {
    Environment = each.key
  })
}

# Create App Services for Worker (background services)
resource "azurerm_linux_web_app" "worker_app" {
  for_each = toset(local.environments)

  name                = "worker-${local.project_name}-${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  service_plan_id     = azurerm_service_plan.app_service_plan[each.key].id

  site_config {
    application_stack {
      docker_image_name = "${azurerm_container_registry.acr.login_server}/worker:${each.key == "prod" ? "latest" : each.key}"
    }

    always_on = true
  }

  # Configure container-specific settings
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"    = "false"
    "DOCKER_ENABLE_CI"                       = "true"
    "ASPNETCORE_ENVIRONMENT"                 = each.key
    "DOTNET_ENVIRONMENT"                     = each.key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.app_insights[each.key].connection_string
    "APPLICATIONINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app_insights[each.key].instrumentation_key
  }

  # Assign the user-assigned identity to the App Service
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity[each.key].id]
  }

  # Configure Key Vault access for secrets
  key_vault_reference_identity_id = azurerm_user_assigned_identity.app_identity[each.key].id

  tags = merge(local.tags, {
    Environment = each.key
    Type        = "Worker"
  })
}

