output "project_name" {
  value = azuredevops_project.project.name
}

output "service_connection_id" {
  value = azuredevops_serviceendpoint_azurerm.service_connection.id
}

output "service_principal_app_id" {
  value = azuread_service_principal.sp.application_id
}

output "service_principal_password" {
  value     = azuread_service_principal_password.sp_password.value
  sensitive = true
}