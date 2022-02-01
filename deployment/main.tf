# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.91.0"
    }
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
  public_key          = "~/.ssh/id_rsa.pub"
}
