# Variables for the Fiscanner infrastructure

variable "subscription_id" {
  description = "The Azure subscription ID where resources will be created."
  type        = string
  default     = "f20b0dac-53ce-44d4-a673-eb1fd36ee03b"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fiscanner"
}

variable "environments" {
  description = "List of environments to create"
  type        = list(string)
  default     = ["dev", "test", "stage", "prod"]
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "app_service_plan_sku" {
  description = "SKU for App Service Plans"
  type        = map(string)
  default = {
    dev   = "B1"
    test  = "B1"
    stage = "S1"
    prod  = "P1v2"
  }
}

variable "dotnet_version" {
  description = ".NET version for the applications"
  type        = string
  default     = "9.0"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "fiscanner"
    ManagedBy = "Terraform"
    Owner     = "Genocs"
  }
}

variable "container_registry_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Standard"
}

variable "container_images" {
  description = "Container image names for the applications"
  type        = map(string)
  default = {
    web_app = "fiscanner-webapi"
    worker  = "fiscanner-worker"
  }
}

variable "enable_container_webhooks" {
  description = "Enable webhooks for automatic container deployment"
  type        = bool
  default     = true
}

variable "log_analytics_retention_days" {
  description = "Log Analytics Workspace retention period in days"
  type        = number
  default     = 30
}

variable "monitoring_email" {
  description = "Email address for monitoring alerts"
  type        = string
  default     = "giovanni.nocco@gmail.com"
}

variable "enable_availability_tests" {
  description = "Enable availability tests for web applications"
  type        = bool
  default     = true
}

variable "app_insights_sampling_percentage" {
  description = "Application Insights sampling percentage by environment"
  type        = map(number)
  default = {
    dev   = 50
    test  = 50
    stage = 75
    prod  = 100
  }
}
