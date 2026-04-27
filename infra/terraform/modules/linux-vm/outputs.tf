output "vm_name" {
  description = "VM name"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_id" {
  description = "VM ID"
  value       = azurerm_linux_virtual_machine.main.id
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "network_interface_id" {
  description = "NIC ID"
  value       = azurerm_network_interface.main.id
}

output "principal_id" {
  description = "System-assigned managed identity principal ID, if enabled"
  value       = try(azurerm_linux_virtual_machine.main.identity[0].principal_id, null)
}
