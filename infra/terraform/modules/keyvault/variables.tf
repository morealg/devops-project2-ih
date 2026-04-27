variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
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
  description = "Current user's Azure AD object ID for Key Vault access policy"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for Key Vault private endpoint"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID for Private DNS link"
  type        = string
}

variable "additional_secret_reader_object_ids" {
  description = "Additional Entra object IDs that should be able to read Key Vault secrets"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
