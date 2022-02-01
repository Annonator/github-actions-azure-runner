variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "myResourceGroup"
}

variable "location" {
  default     = "eastus"
  description = "Location where resources will be created"
}

variable "name" {
  description = "The name of the function app and plan"
}

variable "vmss_rg_name" {
  description = "Name of the resource group in which the VMSS resource is created"
}

variable "vmss_name" {
  description = "Name of the VMSS"
}