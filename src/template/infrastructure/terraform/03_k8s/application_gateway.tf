# Create Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "appgw-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags

  sku {
    name = var.appgw_sku_name
    tier = var.appgw_sku_tier
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Backend Address Pool for AKS
  backend_address_pool {
    name  = "aks-backend-pool"
    fqdns = []
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "aks-backend-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "aks-health-probe"
  }

  # Health Probe
  probe {
    name                = "aks-health-probe"
    protocol            = "Http"
    path                = "/health"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  # HTTP Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  # HTTPS Listener (for future SSL configuration)
  # http_listener {
  #   name                           = "https-listener"
  #   frontend_ip_configuration_name = "appGatewayFrontendIP"
  #   frontend_port_name             = "https"
  #   protocol                       = "Https"
  #   ssl_certificate_name           = "default-ssl-cert"
  # }

  # Default SSL Certificate (will be configured after Key Vault certificate is created)
  # ssl_certificate {
  #   name     = "default-ssl-cert"
  #   data     = azurerm_key_vault_certificate.appgw_ssl.certificate_data
  #   password = ""
  # }

  # Request Routing Rule for HTTP
  request_routing_rule {
    name                       = "http-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "aks-backend-pool"
    backend_http_settings_name = "aks-backend-settings"
    priority                   = 100
  }

  # Request Routing Rule for HTTPS (commented out until SSL is configured)
  # request_routing_rule {
  #   name                       = "https-routing-rule"
  #   rule_type                  = "Basic"
  #   http_listener_name         = "https-listener"
  #   backend_address_pool_name  = "aks-backend-pool"
  #   backend_http_settings_name = "aks-backend-settings"
  #   priority                   = 200
  # }

  # Web Application Firewall Configuration
  waf_configuration {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
    request_body_check       = true
    max_request_body_size_kb = 128
    file_upload_limit_mb     = 100
  }

  # Autoscaling Configuration
  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }

  # Depends on network resources
  depends_on = [
    azurerm_subnet.appgw,
    azurerm_public_ip.appgw
  ]
}

# SSL certificates will be managed through Key Vault
# Self-signed certificates can be created later if needed

# Create Application Gateway Identity for AGIC
resource "azurerm_user_assigned_identity" "appgw" {
  name                = "identity-appgw-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Assign Contributor role to Application Gateway identity
resource "azurerm_role_assignment" "appgw_contributor" {
  scope                = azurerm_application_gateway.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.appgw.principal_id
}

# Assign Reader role to Application Gateway identity for Resource Group
resource "azurerm_role_assignment" "appgw_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.appgw.principal_id
}
