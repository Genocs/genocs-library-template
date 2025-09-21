# Azure Container Registry and Managed Identities for Fiscanner

# Create a single Azure Container Registry (shared across environments)
resource "azurerm_container_registry" "acr" {
  name                = "acr${local.project_name}"
  resource_group_name = azurerm_resource_group.rg["dev"].name # Use dev resource group for ACR
  location            = azurerm_resource_group.rg["dev"].location
  sku                 = "Standard"
  admin_enabled       = true

  tags = merge(local.tags, {
    Purpose = "Container Registry"
  })
}

# Create User Assigned Managed Identities for each environment
resource "azurerm_user_assigned_identity" "app_identity" {
  for_each = toset(local.environments)

  name                = "identity${local.project_name}${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location

  tags = merge(local.tags, {
    Environment = each.key
    Purpose     = "App Service Identity"
  })
}

# Grant ACR pull permissions to each managed identity
resource "azurerm_role_assignment" "acr_pull" {
  for_each = toset(local.environments)

  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app_identity[each.key].principal_id

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_user_assigned_identity.app_identity
  ]
}

# Grant Key Vault access to each managed identity
resource "azurerm_role_assignment" "key_vault_secrets_user" {
  for_each = toset(local.environments)

  scope                = azurerm_key_vault.key_vault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_identity[each.key].principal_id

  depends_on = [
    azurerm_key_vault.key_vault,
    azurerm_user_assigned_identity.app_identity
  ]
}

# Create ACR repository for web application
resource "azurerm_container_registry_webhook" "web_app_webhook" {
  name                = "webapiwebhook${local.project_name}"
  resource_group_name = azurerm_resource_group.rg["dev"].name
  registry_name       = azurerm_container_registry.acr.name
  location            = azurerm_container_registry.acr.location

  service_uri = "https://${azurerm_linux_web_app.web_app["dev"].site_credential[0].name}:${azurerm_linux_web_app.web_app["dev"].site_credential[0].password}@${azurerm_linux_web_app.web_app["dev"].name}.scm.azurewebsites.net/api/registry/webhook"

  actions = ["push"]
  status  = "enabled"

  custom_headers = {
    "Content-Type" = "application/json"
  }

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_linux_web_app.web_app
  ]
}

# Create ACR repository for worker application
resource "azurerm_container_registry_webhook" "worker_app_webhook" {
  name                = "workerwebhook${local.project_name}"
  resource_group_name = azurerm_resource_group.rg["dev"].name
  registry_name       = azurerm_container_registry.acr.name
  location            = azurerm_container_registry.acr.location

  service_uri = "https://${azurerm_linux_web_app.worker_app["dev"].site_credential[0].name}:${azurerm_linux_web_app.worker_app["dev"].site_credential[0].password}@${azurerm_linux_web_app.worker_app["dev"].name}.scm.azurewebsites.net/api/registry/webhook"

  actions = ["push"]
  status  = "enabled"

  custom_headers = {
    "Content-Type" = "application/json"
  }

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_linux_web_app.worker_app
  ]
}
