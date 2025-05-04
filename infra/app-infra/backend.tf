# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-storage-rg"
#     storage_account_name = "tfstateaccountdemo"
#     container_name       = "tfstate"
#     key                  = "prod.terraform.tfstate"
#   }
# }

terraform {
  backend "azurerm" {}
}