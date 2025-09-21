# Create User Assigned Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks-identity-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-dns-${var.project_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  # Network Configuration
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    pod_cidr          = var.network_plugin == "kubenet" ? var.pod_cidr : null
    load_balancer_sku = "standard"
  }

  # Default Node Pool
  default_node_pool {
    name                        = "system"
    temporary_name_for_rotation = "systemtemp"
    vm_size                     = var.node_vm_size
    node_count                  = var.enable_auto_scaling ? null : var.node_count
    min_count                   = var.enable_auto_scaling ? var.min_count : null
    max_count                   = var.enable_auto_scaling ? var.max_count : null
    vnet_subnet_id              = azurerm_subnet.aks.id
    os_disk_size_gb             = 128
    os_disk_type                = "Managed"
    type                        = "VirtualMachineScaleSets"
    zones                       = ["1", "2", "3"]

    # Node pool labels and taints
    node_labels = {
      "node-type" = "system"
    }

    # Upgrade settings
    upgrade_settings {
      max_surge = "33%"
    }
  }

  # Identity Configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # RBAC Configuration
  role_based_access_control_enabled = var.enable_rbac

  # Azure Policy
  azure_policy_enabled = var.enable_azure_policy

  # Workload Identity
  oidc_issuer_enabled       = var.enable_oidc_issuer
  workload_identity_enabled = var.enable_workload_identity

  # Monitoring
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
    msi_auth_for_monitoring_enabled = true
  }

  # Private Cluster Configuration
  private_cluster_enabled = var.enable_private_cluster

  # Auto Scaler Profile (only when auto-scaling is enabled)
  dynamic "auto_scaler_profile" {
    for_each = var.enable_auto_scaling ? [1] : []
    content {
      balance_similar_node_groups      = true
      expander                         = "priority"
      max_graceful_termination_sec     = "600"
      max_node_provisioning_time       = "15m"
      max_unready_nodes                = 3
      max_unready_percentage           = 45
      new_pod_scale_up_delay           = "10s"
      scale_down_delay_after_add       = "10m"
      scale_down_delay_after_delete    = "10s"
      scale_down_delay_after_failure   = "3m"
      scan_interval                    = "10s"
      scale_down_utilization_threshold = "0.5"
      skip_nodes_with_local_storage    = false
      skip_nodes_with_system_pods      = true
    }
  }

  # Maintenance Window
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
    allowed {
      day   = "Monday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
    allowed {
      day   = "Tuesday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
    allowed {
      day   = "Wednesday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
    allowed {
      day   = "Thursday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
    allowed {
      day   = "Friday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
    allowed {
      day   = "Saturday"
      hours = [22, 23, 0, 1, 2, 3, 4, 5, 6]
    }
  }

  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  # Azure Key Management Service (optional - commented out for now)
  # key_management_service {
  #   key_vault_key_id = azurerm_key_vault_key.encryption_key.id
  # }

  # Depends on network resources
  depends_on = [
    azurerm_subnet.aks,
    azurerm_user_assigned_identity.aks,
    azurerm_log_analytics_workspace.aks
  ]
}

# Create additional user node pool for applications
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B2s"
  node_count            = var.enable_auto_scaling ? null : 1
  min_count             = var.enable_auto_scaling ? 1 : null
  max_count             = var.enable_auto_scaling ? 3 : null
  vnet_subnet_id        = azurerm_subnet.aks.id
  os_disk_size_gb       = 128
  os_disk_type          = "Managed"
  os_type               = "Linux"
  zones                 = ["1", "2", "3"]

  # Node pool labels and taints
  node_labels = {
    "node-type" = "user"
  }

  node_taints = [
    "workload=user:NoSchedule"
  ]

  # Upgrade settings
  upgrade_settings {
    max_surge = "33%"
  }

  # Node pool tags
  tags = var.tags
}

# Create spot node pool for cost optimization
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B2s"
  node_count            = var.enable_auto_scaling ? null : 0
  min_count             = var.enable_auto_scaling ? 0 : null
  max_count             = var.enable_auto_scaling ? 2 : null
  vnet_subnet_id        = azurerm_subnet.aks.id
  os_disk_size_gb       = 128
  os_disk_type          = "Managed"
  os_type               = "Linux"
  zones                 = ["1", "2", "3"]
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = 0.1

  # Node pool labels and taints
  node_labels = {
    "node-type" = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  # Node pool tags
  tags = var.tags
}

# Assign Contributor role to AKS managed identity for Application Gateway
resource "azurerm_role_assignment" "aks_appgw_contributor" {
  scope                = azurerm_application_gateway.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Assign Reader role to AKS managed identity for Application Gateway Resource Group
resource "azurerm_role_assignment" "aks_appgw_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
