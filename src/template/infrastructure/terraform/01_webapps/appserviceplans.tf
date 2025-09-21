# Create App Service Plans for each environment
resource "azurerm_service_plan" "app_service_plan" {
  for_each = toset(local.environments)

  name                = "asp-${local.project_name}-${each.key}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  os_type             = "Linux"
  sku_name            = each.key == "prod" ? "P1v2" : each.key == "stage" ? "S1" : "B1"

  tags = merge(local.tags, {
    Environment = each.key
  })
}
