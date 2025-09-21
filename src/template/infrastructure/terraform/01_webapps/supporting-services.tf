# Supporting services for the Fiscanner infrastructure

# Create Storage Accounts for each environment
resource "azurerm_storage_account" "storage" {
  for_each = toset(local.environments)

  name                     = "st${replace(local.project_name, "-", "")}${each.key}"
  resource_group_name      = azurerm_resource_group.rg[each.key].name
  location                 = azurerm_resource_group.rg[each.key].location
  account_tier             = "Standard"
  account_replication_type = each.key == "prod" ? "GRS" : "LRS"
  min_tls_version          = "TLS1_2"

  # Enable blob storage for container logs and artifacts
  blob_properties {
    versioning_enabled = each.key == "prod"
    delete_retention_policy {
      days = each.key == "prod" ? 30 : 7
    }
  }

  tags = merge(local.tags, {
    Environment = each.key
  })
}

# Create blob containers for each environment
resource "azurerm_storage_container" "logs" {
  for_each = toset(local.environments)

  name                  = "logs"
  storage_account_id    = azurerm_storage_account.storage[each.key].id
  container_access_type = "private"
}

resource "azurerm_storage_container" "artifacts" {
  for_each = toset(local.environments)

  name                  = "artifacts"
  storage_account_id    = azurerm_storage_account.storage[each.key].id
  container_access_type = "private"
}

resource "azurerm_storage_container" "uploads" {
  for_each = toset(local.environments)

  name                  = "uploads"
  storage_account_id    = azurerm_storage_account.storage[each.key].id
  container_access_type = "private"
}


# Create Key Vault for secrets management
resource "azurerm_key_vault" "key_vault" {
  for_each = toset(local.environments)

  name                        = "kv${local.project_name}${each.key}"
  location                    = azurerm_resource_group.rg[each.key].location
  resource_group_name         = azurerm_resource_group.rg[each.key].name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  tags = merge(local.tags, {
    Environment = each.key
  })
}

# Create Redis Cache for caching
resource "azurerm_redis_cache" "redis" {
  for_each = toset(local.environments)

  name                = "redis${local.project_name}${each.key}"
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  capacity            = each.key == "prod" ? 1 : 0
  family              = "C"
  sku_name            = each.key == "prod" ? "Standard" : "Basic"

  tags = merge(local.tags, {
    Environment = each.key
  })
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}
