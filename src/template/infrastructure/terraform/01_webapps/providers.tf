terraform {

  required_version = ">= 1.12.2"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.40.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

