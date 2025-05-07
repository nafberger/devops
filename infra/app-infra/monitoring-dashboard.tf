
# Azure Monitor Dashboard for unified view
resource "azurerm_portal_dashboard" "monitor_dashboard" {
  name                = "my-helo-monitor-dashboard"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"

  dashboard_properties = <<DASHBOARD
{
  "lenses": {
    "0": {
      "order": 0,
      "parts": {
        "0": {
          "position": {
            "x": 0,
            "y": 0,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "ComponentId",
                "value": "${azurerm_application_insights.webapp.id}"
              },
              {
                "name": "Query",
                "value": "requests | summarize count() by bin(timestamp, 5m) | order by timestamp desc"
              }
            ],
            "type": "Extension/AppInsightsExtension/PartType/AnalyticsPart"
          }
        },
        "1": {
          "position": {
            "x": 6,
            "y": 0,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "ComponentId",
                "value": "${azurerm_application_insights.webapp.id}"
              },
              {
                "name": "Query",
                "value": "exceptions | summarize count() by bin(timestamp, 5m) | order by timestamp desc"
              }
            ],
            "type": "Extension/AppInsightsExtension/PartType/AnalyticsPart"
          }
        },
        "2": {
          "position": {
            "x": 0,
            "y": 4,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "ResourceId",
                "value": "${azurerm_linux_web_app.app.id}"
              },
              {
                "name": "Metric",
                "value": "Http5xx"
              }
            ],
            "type": "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"
          }
        }
      }
    }
  },
  "metadata": {
    "model": {
      "timeRange": {
        "value": {
          "relative": {
            "duration": 24
          }
        },
        "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
      }
    }
  }
}
DASHBOARD
}