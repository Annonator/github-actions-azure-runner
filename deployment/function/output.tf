output "principal_id" {
  value = azurerm_linux_function_app.functionApp.identity.0.principal_id
}

output "tenant_id" {
  value = azurerm_linux_function_app.functionApp.identity.0.tenant_id
}
