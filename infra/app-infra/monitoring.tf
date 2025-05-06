# Create a Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "my-helo-monitoring-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create Application Insights for the Web App
resource "azurerm_application_insights" "webapp" {
  name                = "my-helo-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.monitoring.id
  application_type    = "web"
}

# Configure diagnostic settings for the Web App to stream logs and metrics
resource "azurerm_monitor_diagnostic_setting" "webapp" {
  name                       = "my-helo-monitoring-diagnostic"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Outputs for reference
output "instrumentation_key" {
  value       = azurerm_application_insights.webapp.instrumentation_key
  sensitive   = true
  description = "Instrumentation key for Application Insights"
}

output "connection_string" {
  value       = azurerm_application_insights.webapp.connection_string
  sensitive   = true
  description = "Connection string for Application Insights"
}

output "webapp_url" {
  value       = azurerm_linux_web_app.app.default_hostname
  description = "The URL of the deployed web app"
}