variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sql_server_name" {
  description = "Azure SQL logical server name"
  type        = string
}

variable "sql_database_name" {
  description = "Azure SQL database name"
  type        = string
}

variable "sql_admin_username" {
  description = "Azure SQL administrator username"
  type        = string
}

variable "sql_admin_password" {
  description = "Azure SQL administrator password"
  type        = string
  sensitive   = true
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for SQL private endpoint"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID for Private DNS link"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
