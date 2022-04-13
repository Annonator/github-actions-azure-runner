resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "azurerm_storage_account" "functionStorage" {
  name                     = "store${var.name}w${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "functionPlan" {
  name                = "plan${var.name}w${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "functionApp" {
  name                        = "app${var.name}w${random_string.suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  service_plan_id             = azurerm_service_plan.functionPlan.id
  storage_account_name        = azurerm_storage_account.functionStorage.name
  storage_account_access_key  = azurerm_storage_account.functionStorage.primary_access_key
  functions_extension_version = "~4"
  site_config {
    http2_enabled = true
    application_stack {
      dotnet_version = "6.0"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "VMSS_RG"   = var.vmss_rg_name
    "VMSS_NAME" = var.vmss_name
  }

  depends_on = [
    azurerm_storage_account.functionStorage,
    azurerm_service_plan.functionPlan
  ]
}
