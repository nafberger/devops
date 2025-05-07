# Variables for monitoring customization
variable "alert_email" {
  default = "nafberger@gmail.com"
}

# Log Analytics Workspace for storing logs
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "my-helo-monitoring-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30 # Global retention for all logs
}

# Application Insights for telemetry collection
resource "azurerm_application_insights" "webapp" {
  name                = "my-helo-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.monitoring.id
  application_type    = "web"
}

# Diagnostic settings for minimal API logs
resource "azurerm_monitor_diagnostic_setting" "webapp" {
  name                       = "my-helo-monitoring-diagnostic"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id

  enabled_log {
    category = "AppServiceHTTPLogs" # Captures API request/response data
  }

  enabled_log {
    category = "AppServiceConsoleLogs" # Captures console output
  }

  enabled_log {
    category = "AppServicePlatformLogs" # Platform logs for hosting issues
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [azurerm_linux_web_app.app]
}

# Alert for API performance (request volume and errors)
resource "azurerm_monitor_metric_alert" "api_performance" {
  name                = "my-helo-api-performance-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.app.id]
  description         = "Alert on low request volume (<10 in 5 min) or 5xx errors"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Requests" # Corrected to supported metric
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 10 # Alert if fewer than 10 requests in 5 minutes
  }

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5 # Number of 5xx errors
  }

  window_size = "PT5M"
  frequency   = "PT1M"

  action {
    action_group_id = azurerm_monitor_action_group.demo.id
  }

  depends_on = [azurerm_linux_web_app.app]
}

# Action group for notifications
resource "azurerm_monitor_action_group" "demo" {
  name                = "my-helo-action-group"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "DemoAction"

  email_receiver {
    name                    = "demo-admin"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

# Availability test for the /hello endpoint
resource "azurerm_application_insights_web_test" "uptime" {
  name                    = "my-helo-uptime-test"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  application_insights_id = azurerm_application_insights.webapp.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 60
  enabled                 = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr"]

  configuration = <<XML
<WebTest Name="HeloUptimeTest" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="60" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="https://${azurerm_linux_web_app.app.default_hostname}/hello" ThinkTime="0" Timeout="60" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
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

output "dashboard_url" {
  value       = "https://portal.azure.com/#dashboard/arm${azurerm_portal_dashboard.monitor_dashboard.id}"
  description = "URL to access the Azure Monitor Dashboard"
}

# Sample KQL query for log analysis
# KQL: requests | where url contains '/hello' | summarize RequestCount = count() by bin(timestamp, 5m) | order by timestamp desc
# Analyzes request volume for the /hello endpoint, demonstrating API usage monitoring.