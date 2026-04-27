output "resource_group_name" {
  description = "Main project resource group name"
  value       = data.azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Main project resource group location"
  value       = data.azurerm_resource_group.main.location
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "project_code" {
  description = "Short project code"
  value       = var.project_code
}

output "admin_username" {
  description = "Linux VM admin username"
  value       = var.admin_username
}

output "vnet_name" {
  description = "Project virtual network name"
  value       = module.networking.vnet_name
}

output "subnet_names" {
  description = "Subnet names by tier"
  value       = module.networking.subnet_names
}

output "subnet_ids" {
  description = "Subnet IDs by tier"
  value       = module.networking.subnet_ids
}

output "sql_server_name" {
  description = "Azure SQL server name"
  value       = module.sql.sql_server_name
}

output "sql_server_fqdn" {
  description = "Azure SQL server FQDN"
  value       = module.sql.sql_server_fqdn
}

output "sql_database_name" {
  description = "Azure SQL database name"
  value       = module.sql.sql_database_name
}

output "sql_private_dns_zone_name" {
  description = "SQL private DNS zone name"
  value       = module.sql.sql_private_dns_zone_name
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.key_vault_uri
}

output "key_vault_private_dns_zone_name" {
  description = "Key Vault private DNS zone name"
  value       = module.keyvault.key_vault_private_dns_zone_name
}

output "sql_admin_username_secret_name" {
  description = "SQL admin username secret name"
  value       = module.keyvault.sql_admin_username_secret_name
}

output "sql_admin_password_secret_name" {
  description = "SQL admin password secret name"
  value       = module.keyvault.sql_admin_password_secret_name
}

output "vm_names" {
  description = "Names of the Linux VMs"
  value = {
    web = module.vm_web.vm_name
    api = module.vm_api.vm_name
    ops = module.vm_ops.vm_name
  }
}

output "vm_private_ips" {
  description = "Private IP addresses of the Linux VMs"
  value = {
    web = module.vm_web.private_ip_address
    api = module.vm_api.private_ip_address
    ops = module.vm_ops.private_ip_address
  }
}

output "vm_managed_identity_principal_ids" {
  description = "Managed identity principal IDs for VMs that have them enabled"
  value = {
    web = module.vm_web.principal_id
    api = module.vm_api.principal_id
    ops = module.vm_ops.principal_id
  }
}

output "internal_load_balancers" {
  description = "Internal load balancer names"
  value = {
    web = module.ilb_web.lb_name
    api = module.ilb_api.lb_name
  }
}

output "internal_load_balancer_ips" {
  description = "Internal load balancer frontend private IPs"
  value = {
    web = module.ilb_web.frontend_private_ip
    api = module.ilb_api.frontend_private_ip
  }
}

output "application_gateway_name" {
  description = "Application Gateway name"
  value       = module.app_gateway.application_gateway_name
}

output "application_gateway_public_ip" {
  description = "Application Gateway public IP"
  value       = module.app_gateway.application_gateway_public_ip
}

output "nat_gateway_public_ip" {
  description = "Outbound public IP used by private VMs through the NAT Gateway"
  value       = module.networking.nat_gateway_public_ip
}
