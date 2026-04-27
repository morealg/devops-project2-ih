variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the NIC will be placed"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for admin access"
  type        = string
}

variable "enable_system_assigned_identity" {
  description = "Whether to enable a system-assigned managed identity for the VM"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
