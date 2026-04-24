output "sql_server_name" {
  description = "Azure SQL server name"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Azure SQL server fully qualified domain name"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Azure SQL database name"
  value       = azurerm_mssql_database.main.name
}

output "sql_private_endpoint_id" {
  description = "SQL private endpoint ID"
  value       = azurerm_private_endpoint.sql.id
}

output "sql_private_dns_zone_name" {
  description = "SQL private DNS zone name"
  value       = azurerm_private_dns_zone.sql.name
}
