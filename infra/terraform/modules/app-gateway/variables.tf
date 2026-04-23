variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_code" {
  description = "Short project code"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "frontend_public_ip_name" {
  description = "Public IP name for Application Gateway"
  type        = string
}

variable "frontend_ilb_ip" {
  description = "Frontend ILB private IP"
  type        = string
}

variable "backend_ilb_ip" {
  description = "Backend ILB private IP"
  type        = string
}

variable "certificate_data" {
  description = "Base64-encoded PFX certificate data"
  type        = string
  sensitive   = true
}

variable "certificate_password" {
  description = "Password for PFX certificate"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
