variable "resource_group_name" {
  description = "Resource group name for Terraform state resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name for Terraform remote state"
  type        = string
}

variable "container_name" {
  description = "Blob container name for Terraform state"
  type        = string
}
