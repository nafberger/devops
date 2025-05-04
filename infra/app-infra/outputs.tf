output "app_service_url" {
  value = azurerm_linux_web_app.app.default_hostname 
}

# output "aks_cluster_name" {
#   value = azurerm_kubernetes_cluster.aks.name
# }

output "sql_database_name" {
  value = azurerm_sql_database.sqldb.name
}