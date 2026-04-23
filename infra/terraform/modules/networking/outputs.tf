output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    agw               = azurerm_subnet.agw.id
    web               = azurerm_subnet.web.id
    api               = azurerm_subnet.api.id
    ops               = azurerm_subnet.ops.id
    private_endpoints = azurerm_subnet.private_endpoints.id
  }
}

output "subnet_names" {
  description = "Map of subnet names"
  value = {
    agw               = azurerm_subnet.agw.name
    web               = azurerm_subnet.web.name
    api               = azurerm_subnet.api.name
    ops               = azurerm_subnet.ops.name
    private_endpoints = azurerm_subnet.private_endpoints.name
  }
}

output "nsg_ids" {
  description = "Map of NSG IDs"
  value = {
    web               = azurerm_network_security_group.web.id
    api               = azurerm_network_security_group.api.id
    ops               = azurerm_network_security_group.ops.id
    private_endpoints = azurerm_network_security_group.private_endpoints.id
  }
}
