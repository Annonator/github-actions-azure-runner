variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "myResourceGroup"
}

variable "location" {
  default     = "eastus"
  description = "Location where resources will be created"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    environment = "codelab"
  }
}

variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Password for the users VMSS"
}

variable "public_key" {
  description = "path to you local public key you want to use to login in to servers"
}

variable "disk_size" {
  description = "The Size of the Datadisk attached to each vm"
  default     = 10
}

variable "scaleset_size" {
  description = "The Size of the scaleset"
  default     = 1
}
