resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

resource "azurerm_virtual_network" "vnet-agents" {
  name                = "vnet-agents-prod-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vnet-subnet" {
  name                 = "subnet-agents-prod-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-agents.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip-agents" {
  name                = "pip-agents-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  domain_name_label   = random_string.fqdn.result
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "lb-public" {
  name                = "lb-agents-prod-001"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "pip-agents-prod-001"
    public_ip_address_id = azurerm_public_ip.pip-agents.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-backendpool" {
  loadbalancer_id = azurerm_lb.lb-public.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb-probe" {
  loadbalancer_id = azurerm_lb.lb-public.id
  name            = "running-probe"
  port            = var.application_port
}

resource "azurerm_lb_rule" "lb-public-rule" {
  loadbalancer_id                = azurerm_lb.lb-public.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backendpool.id]
  frontend_ip_configuration_name = azurerm_lb.lb-public.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb-probe.id
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss-agents" {
  name                 = "vmss-agents-prod-001"
  resource_group_name  = var.resource_group_name
  location             = var.location
  sku                  = "Standard_F4s_v2"
  instances            = var.scaleset_size
  admin_password       = var.admin_password
  admin_username       = "agents"
  computer_name_prefix = "agent-"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-core"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  network_interface {
    name                          = "nic-agents-prod"
    enable_accelerated_networking = true
    primary                       = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.vnet-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb-backendpool.id]
    }
  }
}
