variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "name" {
  description = "Load balancer name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the internal load balancer frontend"
  type        = string
}

variable "frontend_private_ip" {
  description = "Static private IP for the internal load balancer frontend"
  type        = string
}

variable "backend_nic_id" {
  description = "Network interface ID to attach to the backend pool"
  type        = string
}

variable "backend_port" {
  description = "Backend application port"
  type        = number
}

variable "probe_port" {
  description = "Health probe port"
  type        = number
}

variable "probe_path" {
  description = "HTTP health probe path"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
