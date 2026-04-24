output "application_gateway_name" {
  description = "Application Gateway name"
  value       = azurerm_application_gateway.main.name
}

output "application_gateway_public_ip" {
  description = "Application Gateway public IP address"
  value       = azurerm_public_ip.appgw.ip_address
}

output "application_gateway_public_ip_id" {
  description = "Application Gateway public IP resource ID"
  value       = azurerm_public_ip.appgw.id
}
