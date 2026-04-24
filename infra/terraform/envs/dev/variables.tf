variable "resource_group_name" {
  description = "Existing Azure resource group name for project resources"
  type        = string
}

variable "location" {
  description = "Azure region for project resources"
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev or prod"
  type        = string
}

variable "project_name" {
  description = "Full project name"
  type        = string
}

variable "project_code" {
  description = "Short project code used in resource names"
  type        = string
}

variable "admin_username" {
  description = "Admin username for Linux VMs"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the project virtual network"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Subnet CIDR ranges for each network tier"
  type        = map(list(string))
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
  description = "Azure SQL admin username"
  type        = string
}

variable "sql_admin_password" {
  description = "Azure SQL admin password"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "current_user_object_id" {
  description = "Current user's Azure AD object ID for Key Vault access"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for Linux VM authentication"
  type        = string
}

variable "vm_sizes" {
  description = "VM sizes for each role"
  type        = map(string)
}

variable "frontend_ilb_ip" {
  description = "Static private IP for frontend internal load balancer"
  type        = string
}

variable "backend_ilb_ip" {
  description = "Static private IP for backend internal load balancer"
  type        = string
}

variable "appgw_certificate_data" {
  description = "Base64-encoded PFX certificate data for Application Gateway"
  type        = string
  sensitive   = true
}


variable "appgw_certificate_password" {
  description = "Password for the Application Gateway PFX certificate"
  type        = string
  sensitive   = true
}

variable "appgw_public_ip_name" {
  description = "Public IP resource name for Application Gateway"
  type        = string
}
