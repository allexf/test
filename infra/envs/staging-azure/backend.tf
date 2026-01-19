terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatestaging"
    container_name       = "tfstate"
    key                  = "staging-azure.tfstate"
  }
}

