
resource "azurerm_service_plan" "plan" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}
resource "azurerm_linux_web_app" "app" {
  name                = "my-helo-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

# resource "azurerm_mssql_server" "sql_server" {
#   name                         = "devops-sql-${random_integer.unique.result}"
#   resource_group_name          = azurerm_resource_group.rg.name
#   location                     = azurerm_resource_group.rg.location
#   version                      = "12.0"
#   administrator_login          = var.sql_admin_username
#   administrator_login_password = var.sql_admin_password

#   identity {
#     type = "SystemAssigned"
#   }

#   tags = {
#     environment = var.environment
#     project     = "devops-demo"
#   }
# }

# resource "azurerm_mssql_database" "sql_db" {
#   name        = "devopsdb"
#   server_id   = azurerm_mssql_server.sql_server.id
#   sku_name    = "S0"
#   collation   = "SQL_Latin1_General_CP1_CI_AS"
#   max_size_gb = 5

#   tags = {
#     environment = var.environment
#     project     = "devops-demo"
#   }
# }

# resource "random_integer" "unique" {
#   min = 1000
#   max = 9999
# }
# resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
#   app_service_id = azurerm_linux_web_app.app.id
#   subnet_id      = azurerm_subnet.subnet.id
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "demo-vnet"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "subnet" {
#   name                 = "appservice-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]

#   delegation {
#     name = "delegation"
#     service_delegation {
#       name = "Microsoft.Web/serverFarms"
#       actions = [
#         "Microsoft.Network/virtualNetworks/subnets/action",
#       ]
#     }
#   }
# }

# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "devops-demo-aks"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "devopsaks"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_B2s"
#   }

#   identity {
#     type = "SystemAssigned"
#   }
# }