variable "resource_group_name" {
  description = "Resource group where networking resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region for networking resources"
  type        = string
}

variable "project_code" {
  description = "Short project code used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  type        = map(list(string))
}

variable "tags" {
  description = "Common tags for all networking resources"
  type        = map(string)
}
