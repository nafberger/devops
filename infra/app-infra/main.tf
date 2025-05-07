# Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan (optimized for minimal API)
resource "azurerm_service_plan" "plan" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1" # Supports monitoring and reliability
}

# Linux Web App configured for minimal API
resource "azurerm_linux_web_app" "app" {
  name                = "my-helo-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true
    application_stack {
      dotnet_version = "8.0"
    }
    app_command_line = "dotnet MyHeloApp.dll --environment Production" # Replace MyHeloApp.dll with your actual DLL
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.webapp.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.webapp.connection_string
    "ASPNETCORE_ENVIRONMENT"                = "Production"
    "Logging__LogLevel__Default"            = "Information" # Ensures detailed logs for minimal API
    "Logging__LogLevel__Microsoft"          = "Warning"     # Reduces noise from framework logs
  }
}