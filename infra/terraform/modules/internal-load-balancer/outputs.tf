output "lb_id" {
  description = "Internal load balancer ID"
  value       = azurerm_lb.main.id
}

output "lb_name" {
  description = "Internal load balancer name"
  value       = azurerm_lb.main.name
}

output "frontend_private_ip" {
  description = "Frontend private IP of the internal load balancer"
  value       = var.frontend_private_ip
}

output "backend_pool_id" {
  description = "Backend address pool ID"
  value       = azurerm_lb_backend_address_pool.main.id
}
