provider "time" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "azuredevops" {
  personal_access_token = var.azure_devops_pat
  org_service_url       = var.azure_devops_org_url
}

provider "azuread" {
  client_id     = var.client_id
  client_secret = var.client_secret
  tenant_id     = var.tenant_id
}

data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.customer_name}-rg"
  location = var.region
}

resource "azuread_application" "sp_app" {
  display_name = "${var.customer_name}-app"
}

resource "azuread_service_principal" "sp" {
  client_id                    = azuread_application.sp_app.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "random_password" "sp_pwd" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "sp_password" {
  service_principal_id = azuread_service_principal.sp.id
  display_name         = "sp-password"
  end_date             = timeadd(timestamp(), "8760h")
}

resource "azurerm_role_assignment" "sp_role" {
  principal_id         = azuread_service_principal.sp.id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

resource "azuredevops_project" "project" {
  name               = var.customer_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_serviceendpoint_azurerm" "service_connection" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "${var.customer_name}-serviceconn"

  credentials {
    serviceprincipalid  = azuread_service_principal.sp.client_id
    serviceprincipalkey = azuread_service_principal_password.sp_password.value
  }

  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = "Customer Subscription"
}