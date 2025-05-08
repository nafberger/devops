# Storage Account for Azure Function
resource "azurerm_storage_account" "function_storage" {
  name                     = "myhelostorage${random_integer.unique.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "my-helo-function-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"  # ✅ use Windows to stay in Australia
  sku_name            = "Y1"       # Still Consumption
}

# Function App (Windows)
resource "azurerm_windows_function_app" "function" {
  name                       = "my-helo-function"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  site_config {
    application_stack {
      dotnet_version = "v8.0"  # ✅ Valid for Windows
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "dotnet"  # ✅ correct for .NET 6/7/8
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.webapp.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.webapp.connection_string
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"  # ✅ common for .NET isolated functions
  }
}

resource "random_integer" "unique" {
  min = 1000
  max = 9999
}