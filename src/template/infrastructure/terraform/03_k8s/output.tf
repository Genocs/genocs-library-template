# Output Resource Group information
output "resource_group" {
  description = "Resource Group details"
  value = {
    name     = azurerm_resource_group.main.name
    location = azurerm_resource_group.main.location
    id       = azurerm_resource_group.main.id
  }
}

# Output Virtual Network information
output "virtual_network" {
  description = "Virtual Network details"
  value = {
    name          = azurerm_virtual_network.main.name
    id            = azurerm_virtual_network.main.id
    address_space = azurerm_virtual_network.main.address_space
  }
}

# Output Subnet information
output "subnets" {
  description = "Subnet details"
  value = {
    aks = {
      name           = azurerm_subnet.aks.name
      id             = azurerm_subnet.aks.id
      address_prefix = var.aks_subnet_address_prefix
    }
    appgw = {
      name           = azurerm_subnet.appgw.name
      id             = azurerm_subnet.appgw.id
      address_prefix = var.appgw_subnet_address_prefix
    }
    nat_gateway = {
      name           = azurerm_subnet.nat_gateway.name
      id             = azurerm_subnet.nat_gateway.id
      address_prefix = var.nat_gateway_subnet_address_prefix
    }
  }
}

# Output NAT Gateway information
output "nat_gateway" {
  description = "NAT Gateway details"
  value = {
    name         = azurerm_nat_gateway.main.name
    id           = azurerm_nat_gateway.main.id
    public_ip_id = azurerm_public_ip.nat_gateway.id
    public_ip    = azurerm_public_ip.nat_gateway.ip_address
  }
}

# Output AKS Cluster information
output "aks_cluster" {
  description = "AKS Cluster details"
  value = {
    name                   = azurerm_kubernetes_cluster.main.name
    id                     = azurerm_kubernetes_cluster.main.id
    fqdn                   = azurerm_kubernetes_cluster.main.fqdn
    private_fqdn           = azurerm_kubernetes_cluster.main.private_fqdn
    portal_fqdn            = azurerm_kubernetes_cluster.main.portal_fqdn
    kubernetes_version     = azurerm_kubernetes_cluster.main.kubernetes_version
    node_resource_group    = azurerm_kubernetes_cluster.main.node_resource_group
    kube_config_raw        = azurerm_kubernetes_cluster.main.kube_config_raw
    host                   = azurerm_kubernetes_cluster.main.kube_config[0].host
    client_key             = azurerm_kubernetes_cluster.main.kube_config[0].client_key
    client_certificate     = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
    cluster_ca_certificate = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  }
  sensitive = true
}

# Output AKS Node Pools information
output "aks_node_pools" {
  description = "AKS Node Pools details"
  value = {
    system = {
      name         = azurerm_kubernetes_cluster.main.default_node_pool[0].name
      vm_size      = azurerm_kubernetes_cluster.main.default_node_pool[0].vm_size
      node_count   = azurerm_kubernetes_cluster.main.default_node_pool[0].node_count
      min_count    = azurerm_kubernetes_cluster.main.default_node_pool[0].min_count
      max_count    = azurerm_kubernetes_cluster.main.default_node_pool[0].max_count
      auto_scaling = var.enable_auto_scaling
    }
    user = {
      name         = azurerm_kubernetes_cluster_node_pool.user.name
      vm_size      = azurerm_kubernetes_cluster_node_pool.user.vm_size
      node_count   = azurerm_kubernetes_cluster_node_pool.user.node_count
      min_count    = azurerm_kubernetes_cluster_node_pool.user.min_count
      max_count    = azurerm_kubernetes_cluster_node_pool.user.max_count
      auto_scaling = true
    }
    spot = {
      name         = azurerm_kubernetes_cluster_node_pool.spot.name
      vm_size      = azurerm_kubernetes_cluster_node_pool.spot.vm_size
      node_count   = azurerm_kubernetes_cluster_node_pool.spot.node_count
      min_count    = azurerm_kubernetes_cluster_node_pool.spot.min_count
      max_count    = azurerm_kubernetes_cluster_node_pool.spot.max_count
      auto_scaling = true
      priority     = azurerm_kubernetes_cluster_node_pool.spot.priority
    }
  }
}

# Output Application Gateway information
output "application_gateway" {
  description = "Application Gateway details"
  value = {
    name         = azurerm_application_gateway.main.name
    id           = azurerm_application_gateway.main.id
    public_ip_id = azurerm_public_ip.appgw.id
    public_ip    = azurerm_public_ip.appgw.ip_address
    fqdn         = azurerm_public_ip.appgw.fqdn
    sku_name     = azurerm_application_gateway.main.sku[0].name
    sku_tier     = azurerm_application_gateway.main.sku[0].tier
    capacity     = azurerm_application_gateway.main.sku[0].capacity
  }
}

# Output Managed Identities information
output "managed_identities" {
  description = "Managed Identity details"
  value = {
    aks = {
      name         = azurerm_user_assigned_identity.aks.name
      id           = azurerm_user_assigned_identity.aks.id
      principal_id = azurerm_user_assigned_identity.aks.principal_id
      client_id    = azurerm_user_assigned_identity.aks.client_id
    }
    appgw = {
      name         = azurerm_user_assigned_identity.appgw.name
      id           = azurerm_user_assigned_identity.appgw.id
      principal_id = azurerm_user_assigned_identity.appgw.principal_id
      client_id    = azurerm_user_assigned_identity.appgw.client_id
    }
  }
}

# Output Log Analytics Workspace information
output "log_analytics_workspace" {
  description = "Log Analytics Workspace details"
  value = {
    name                 = azurerm_log_analytics_workspace.aks.name
    id                   = azurerm_log_analytics_workspace.aks.id
    workspace_id         = azurerm_log_analytics_workspace.aks.workspace_id
    primary_shared_key   = azurerm_log_analytics_workspace.aks.primary_shared_key
    secondary_shared_key = azurerm_log_analytics_workspace.aks.secondary_shared_key
  }
  sensitive = true
}

# Output AGIC information
output "agic" {
  description = "AGIC (Application Gateway Ingress Controller) details"
  value = {
    installation_guide = "agic-installation-guide.md"
    sample_manifest = "sample-app-manifest.yaml"
    namespace = "agic-system"
  }
}

# Output Key Vault information
output "key_vault" {
  description = "Key Vault details"
  value = {
    name                = azurerm_key_vault.main.name
    id                  = azurerm_key_vault.main.id
    uri                 = azurerm_key_vault.main.vault_uri
    location            = azurerm_key_vault.main.location
    resource_group_name = azurerm_key_vault.main.resource_group_name
    sku_name            = azurerm_key_vault.main.sku_name
    tenant_id           = azurerm_key_vault.main.tenant_id
    enabled_for_disk_encryption     = azurerm_key_vault.main.enabled_for_disk_encryption
    enabled_for_deployment          = azurerm_key_vault.main.enabled_for_deployment
    enabled_for_template_deployment = azurerm_key_vault.main.enabled_for_template_deployment
    enable_rbac_authorization       = azurerm_key_vault.main.enable_rbac_authorization
    purge_protection_enabled        = azurerm_key_vault.main.purge_protection_enabled
    soft_delete_retention_days      = azurerm_key_vault.main.soft_delete_retention_days
  }
}

# Output Key Vault secrets information
output "key_vault_secrets" {
  description = "Key Vault secrets details"
  value = {
    aks_kubeconfig = {
      name  = azurerm_key_vault_secret.aks_kubeconfig.name
      id    = azurerm_key_vault_secret.aks_kubeconfig.id
    }
    appgw_public_ip = {
      name  = azurerm_key_vault_secret.appgw_public_ip.name
      id    = azurerm_key_vault_secret.appgw_public_ip.id
    }
    log_analytics_workspace_id = {
      name  = azurerm_key_vault_secret.log_analytics_workspace_id.name
      id    = azurerm_key_vault_secret.log_analytics_workspace_id.id
    }
    database_connection_string = {
      name  = azurerm_key_vault_secret.database_connection_string.name
      id    = azurerm_key_vault_secret.database_connection_string.id
    }
    api_key = {
      name  = azurerm_key_vault_secret.api_key.name
      id    = azurerm_key_vault_secret.api_key.id
    }
  }
}

# Output Key Vault certificates information
output "key_vault_certificates" {
  description = "Key Vault certificates details"
  value = {
    appgw_ssl_cert = {
      name     = azurerm_key_vault_certificate.appgw_ssl.name
      id       = azurerm_key_vault_certificate.appgw_ssl.id
      version  = azurerm_key_vault_certificate.appgw_ssl.version
      thumbprint = azurerm_key_vault_certificate.appgw_ssl.thumbprint
    }
  }
}

# Output Key Vault keys information
output "key_vault_keys" {
  description = "Key Vault keys details"
  value = {
    encryption_key = {
      name     = azurerm_key_vault_key.encryption_key.name
      id       = azurerm_key_vault_key.encryption_key.id
      version  = azurerm_key_vault_key.encryption_key.version
      key_type = azurerm_key_vault_key.encryption_key.key_type
      key_size = azurerm_key_vault_key.encryption_key.key_size
    }
  }
}

# Output connection information
output "connection_info" {
  description = "Connection information for the AKS cluster"
  value = {
    kubectl_config           = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
    application_gateway_url  = "http://${azurerm_public_ip.appgw.ip_address}"
    application_gateway_fqdn = azurerm_public_ip.appgw.fqdn
    key_vault_uri            = azurerm_key_vault.main.vault_uri
  }
}

