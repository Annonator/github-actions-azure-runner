resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "azurerm_storage_account" "functionStorage" {
  name                     = "store-${var.name}-${radom_string.suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "functionPlan" {
  name                = "plan-${var.name}-${radom_string.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "functionApp" {
  name                       = "app-${var.name}-${radom_string.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.functionPlan.id
  storage_account_name       = azurerm_storage_account.functionStorage.name
  storage_account_access_key = azurerm_storage_account.functionStorage.primary_access_key
  os_type                    = "linux"
  version                    = "~4"
  site_config {
    dotnet_framework_version = "v6.0"
  }
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "VMSS_RG"   = var.vmss_rg_name
    "VMSS_NAME" = var.vmss_name
  }
}
