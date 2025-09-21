# Create resource groups for different environments
locals {
  project_name = var.project_name
  environments = var.environments
  location     = var.location
  tags         = var.tags
}

# Create resource groups for each environment
resource "azurerm_resource_group" "rg" {
  for_each = toset(local.environments)

  name     = "rg-${local.project_name}-${each.key}"
  location = local.location

  tags = merge(local.tags, {
    Environment = each.key
  })
}
