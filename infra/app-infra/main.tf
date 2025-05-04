
resource "azurerm_service_plan" "plan" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B1"
  os_type             = "Linux" # or "Windows"
}

resource "azurerm_linux_web_app" "app" {
  name                = "my-helo-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id

    site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

resource "azurerm_sql_server" "sqlserver" {
  name                         = "devopsdemosqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "YourStrongPassword123!"
}

resource "azurerm_sql_database" "sqldb" {
  name                             = "devopsdemodb"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  server_name                      = azurerm_sql_server.sqlserver.name
  requested_service_objective_name = "S0"
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.subnet.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "appservice-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

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