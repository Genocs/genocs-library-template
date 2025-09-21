# Create Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku_name
  tags                = var.tags

  # Security settings
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_enable_purge_protection

  # Soft delete settings
  soft_delete_retention_days = var.key_vault_enable_soft_delete ? var.key_vault_soft_delete_retention_days : null

  # Network ACLs
  network_acls {
    default_action             = var.key_vault_network_acls.default_action
    bypass                     = var.key_vault_network_acls.bypass
    virtual_network_subnet_ids = var.key_vault_network_acls.virtual_network_subnet_ids
    ip_rules                   = var.key_vault_network_acls.ip_rules
  }

  # Access policies (only used when RBAC is disabled)
  dynamic "access_policy" {
    for_each = var.key_vault_enable_rbac_authorization ? [] : var.key_vault_access_policies
    content {
      tenant_id = access_policy.value.tenant_id
      object_id = access_policy.value.object_id

      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      certificate_permissions = access_policy.value.certificate_permissions
    }
  }

  depends_on = [azurerm_resource_group.main]
}

# Get current Azure client configuration (already declared in agic.tf)

# RBAC role assignments for Key Vault (when RBAC is enabled)
resource "azurerm_role_assignment" "key_vault_aks_identity" {
  count                = var.key_vault_enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_role_assignment" "key_vault_appgw_identity" {
  count                = var.key_vault_enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.appgw.principal_id
}

# Assign Key Vault Administrator role to current user (for initial setup)
resource "azurerm_role_assignment" "key_vault_admin" {
  count                = var.key_vault_enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Create Key Vault secrets for common configurations
resource "azurerm_key_vault_secret" "aks_kubeconfig" {
  name         = "aks-kubeconfig"
  value        = azurerm_kubernetes_cluster.main.kube_config_raw
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "appgw_public_ip" {
  name         = "appgw-public-ip"
  value        = azurerm_public_ip.appgw.ip_address
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "log_analytics_workspace_id" {
  name         = "log-analytics-workspace-id"
  value        = azurerm_log_analytics_workspace.aks.workspace_id
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}

# Create Key Vault certificate for Application Gateway (alternative to self-signed)
resource "azurerm_key_vault_certificate" "appgw_ssl" {
  name         = "appgw-ssl-cert"
  key_vault_id = azurerm_key_vault.main.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${var.project_name}-${var.environment}.local"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = compact([
          "${var.project_name}-${var.environment}.local",
          "*.${var.project_name}-${var.environment}.local",
          azurerm_public_ip.appgw.fqdn
        ])
      }
    }
  }

  tags = var.tags

  depends_on = [azurerm_key_vault.main]
}

# Create Key Vault key for encryption
resource "azurerm_key_vault_key" "encryption_key" {
  name         = "encryption-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags

  depends_on = [azurerm_key_vault.main]
}

# Create sample secrets for applications
resource "azurerm_key_vault_secret" "database_connection_string" {
  name         = "database-connection-string"
  value        = "Server=tcp:${var.project_name}-${var.environment}-sql.database.windows.net,1433;Initial Catalog=${var.project_name}db;Persist Security Info=False;User ID=admin;Password=YourPassword123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.main.id
  tags = merge(var.tags, {
    Description = "Database connection string for applications"
    Environment = var.environment
  })

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  value        = "your-api-key-here"
  key_vault_id = azurerm_key_vault.main.id
  tags = merge(var.tags, {
    Description = "API key for external services"
    Environment = var.environment
  })

  depends_on = [azurerm_key_vault.main]
}

# Create Key Vault access policy for AKS CSI driver (when RBAC is disabled)
resource "azurerm_key_vault_access_policy" "aks_csi_driver" {
  count        = var.key_vault_enable_rbac_authorization ? 0 : 1
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.aks.principal_id

  key_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]
}

# Create Key Vault access policy for Application Gateway (when RBAC is disabled)
resource "azurerm_key_vault_access_policy" "appgw" {
  count        = var.key_vault_enable_rbac_authorization ? 0 : 1
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.appgw.principal_id

  key_permissions = [
    "Get",
    "List",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

  certificate_permissions = [
    "Get",
    "List",
  ]
}
