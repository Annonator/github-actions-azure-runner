# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-prod"
    storage_account_name = "andyterra"
    container_name       = "terraform"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgActionEndpoint" {
  name     = "rg-github-action-endpoint-prod"
  location = "westeurope"
}

resource "azurerm_resource_group" "rgActionAgents" {
  name     = "rg-github-action-agents-prod"
  location = "westeurope"
}

module "vmss" {
  source              = "./vmss"
  resource_group_name = azurerm_resource_group.rgActionAgents.name
  location            = azurerm_resource_group.rgActionAgents.location
  admin_user          = "actions"
  admin_password      = ""
  public_key          = "~/.ssh/id_rsa.pub"
  scaleset_size       = 3
}

module "function" {
  source              = "./function"
  resource_group_name = azurerm_resource_group.rgActionEndpoint.name
  location            = azurerm_resource_group.rgActionEndpoint.location
  name                = "andytest"
  vmss_rg_name        = azurerm_resource_group.rgActionAgents.name
  vmss_name           = "vmscaleset"
}
