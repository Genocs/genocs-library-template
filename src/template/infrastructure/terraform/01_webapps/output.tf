# Output resource group names
output "resource_group_names" {
  description = "Names of the created resource groups"
  value = {
    for env in local.environments : env => azurerm_resource_group.rg[env].name
  }
}

# Output App Service Plan names
output "app_service_plan_names" {
  description = "Names of the created App Service Plans"
  value = {
    for env in local.environments : env => azurerm_service_plan.app_service_plan[env].name
  }
}

# Output Web App names
output "web_app_names" {
  description = "Names of the created Web Apps"
  value = {
    for env in local.environments : env => azurerm_linux_web_app.web_app[env].name
  }
}

# Output Worker App names
output "worker_app_names" {
  description = "Names of the created Worker Apps"
  value = {
    for env in local.environments : env => azurerm_linux_web_app.worker_app[env].name
  }
}

# Output Web App URLs
output "web_app_urls" {
  description = "URLs of the created Web Apps"
  value = {
    for env in local.environments : env => azurerm_linux_web_app.web_app[env].default_hostname
  }
}

# Output Worker App URLs
output "worker_app_urls" {
  description = "URLs of the created Worker Apps"
  value = {
    for env in local.environments : env => azurerm_linux_web_app.worker_app[env].default_hostname
  }
}

# Output resource group locations
output "resource_group_locations" {
  description = "Locations of the created resource groups"
  value = {
    for env in local.environments : env => azurerm_resource_group.rg[env].location
  }
}

# Output Storage Account names
output "storage_account_names" {
  description = "Names of the created Storage Accounts"
  value = {
    for env in local.environments : env => azurerm_storage_account.storage[env].name
  }
}

# Output Application Insights names
output "app_insights_names" {
  description = "Names of the created Application Insights"
  value = {
    for env in local.environments : env => azurerm_application_insights.app_insights[env].name
  }
}

# Output Key Vault names
output "key_vault_names" {
  description = "Names of the created Key Vaults"
  value = {
    for env in local.environments : env => azurerm_key_vault.key_vault[env].name
  }
}

# Output Redis Cache names
output "redis_cache_names" {
  description = "Names of the created Redis Caches"
  value = {
    for env in local.environments : env => azurerm_redis_cache.redis[env].name
  }
}

# Output Container Registry information
output "container_registry" {
  description = "Azure Container Registry details"
  value = {
    name           = azurerm_container_registry.acr.name
    login_server   = azurerm_container_registry.acr.login_server
    admin_username = azurerm_container_registry.acr.admin_username
    admin_password = azurerm_container_registry.acr.admin_password
  }
  sensitive = true
}

# Output Managed Identity information
output "managed_identities" {
  description = "Managed Identity details for each environment"
  value = {
    for env in local.environments : env => {
      name         = azurerm_user_assigned_identity.app_identity[env].name
      principal_id = azurerm_user_assigned_identity.app_identity[env].principal_id
      client_id    = azurerm_user_assigned_identity.app_identity[env].client_id
    }
  }
}

# Output Storage Container names
output "storage_containers" {
  description = "Storage container names for each environment"
  value = {
    for env in local.environments : env => {
      logs      = azurerm_storage_container.logs[env].name
      artifacts = azurerm_storage_container.artifacts[env].name
      uploads   = azurerm_storage_container.uploads[env].name
    }
  }
}

# Output Log Analytics Workspace information
output "log_analytics_workspace" {
  description = "Log Analytics Workspace details"
  value = {
    name                 = azurerm_log_analytics_workspace.log_analytics.name
    workspace_id         = azurerm_log_analytics_workspace.log_analytics.workspace_id
    primary_shared_key   = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
    secondary_shared_key = azurerm_log_analytics_workspace.log_analytics.secondary_shared_key
  }
  sensitive = true
}

# Output Application Insights information
output "application_insights" {
  description = "Application Insights details for each environment"
  value = {
    for env in local.environments : env => {
      name                = azurerm_application_insights.app_insights[env].name
      instrumentation_key = azurerm_application_insights.app_insights[env].instrumentation_key
      connection_string   = azurerm_application_insights.app_insights[env].connection_string
      app_id              = azurerm_application_insights.app_insights[env].app_id
    }
  }
  sensitive = true
}

# Output Action Group information
output "action_group" {
  description = "Action Group details"
  value = {
    name       = azurerm_monitor_action_group.main.name
    id         = azurerm_monitor_action_group.main.id
    short_name = azurerm_monitor_action_group.main.short_name
  }
}

