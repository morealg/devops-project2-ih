output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_private_dns_zone_name" {
  description = "Key Vault private DNS zone name"
  value       = azurerm_private_dns_zone.keyvault.name
}

output "sql_admin_username_secret_name" {
  description = "Planned Key Vault secret name for SQL admin username"
  value       = "sql-admin-username"
}

output "sql_admin_password_secret_name" {
  description = "Planned Key Vault secret name for SQL admin password"
  value       = "sql-admin-password"
}
