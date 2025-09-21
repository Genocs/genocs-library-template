# Monitoring and Logging Infrastructure for Fiscanner

# Create a shared Log Analytics Workspace (shared across environments)
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "analytics-ws${local.project_name}"
  location            = azurerm_resource_group.rg["dev"].location
  resource_group_name = azurerm_resource_group.rg["dev"].name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(local.tags, {
    Purpose = "Centralized Logging"
  })
}

# Enhanced Application Insights for each environment
resource "azurerm_application_insights" "app_insights" {
  for_each = toset(local.environments)

  name                = "appinsights-${local.project_name}${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id

  # Enable sampling for cost optimization
  sampling_percentage = each.key == "prod" ? 100 : 50

  # Enable web test for availability monitoring
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = merge(local.tags, {
    Environment = each.key
  })
}

# Create Log Analytics Solutions for enhanced monitoring
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.log_analytics.location
  resource_group_name   = azurerm_log_analytics_workspace.log_analytics.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = merge(local.tags, {
    Purpose = "Container Monitoring"
  })
}

resource "azurerm_log_analytics_solution" "service_map" {
  solution_name         = "ServiceMap"
  location              = azurerm_log_analytics_workspace.log_analytics.location
  resource_group_name   = azurerm_log_analytics_workspace.log_analytics.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ServiceMap"
  }

  tags = merge(local.tags, {
    Purpose = "Service Dependency Mapping"
  })
}

# Note: Diagnostic settings can be configured manually in Azure Portal
# or through Azure CLI after deployment for better compatibility

# Create Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "action-group${local.project_name}"
  resource_group_name = azurerm_resource_group.rg["dev"].name
  short_name          = "fiscanner"

  email_receiver {
    name                    = "devops-team"
    email_address          = "devops@genocs.com"
    use_common_alert_schema = true
  }

  tags = merge(local.tags, {
    Purpose = "Alerting"
  })
}

# Create Availability Test for Web App
resource "azurerm_application_insights_web_test" "web_app_availability" {
  for_each = toset(local.environments)

  name                    = "availability-test${local.project_name}${each.key}"
  resource_group_name     = azurerm_resource_group.rg[each.key].name
  application_insights_id = azurerm_application_insights.app_insights[each.key].id
  location                = azurerm_application_insights.app_insights[each.key].location
  kind                    = "ping"
  geo_locations           = ["emea-nl-ams-azr"]

  configuration = <<XML
<?xml version="1.0" encoding="utf-8"?>
<WebTest Name="WebTest1" Id="ABD48585-0B6F-4E31-84D5-9C937D7C0A85" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="30" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea439b9f489" Version="1.1" Url="https://${azurerm_linux_web_app.web_app[each.key].default_hostname}/health" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

  tags = merge(local.tags, {
    Environment = each.key
  })
}
