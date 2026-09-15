output "lb" {
  description = "contains load balancer configuration"
  value       = azurerm_lb.this
}

output "rules" {
  description = "contains load balancer rules"
  value       = azurerm_lb_rule.this
}

output "nat_pools" {
  description = "contains load balancer nat pools"
  value       = azurerm_lb_nat_pool.this
}

output "nat_rules" {
  description = "contains load balancer nat rules"
  value       = azurerm_lb_nat_rule.this
}

output "probes" {
  description = "contains load balancer probes"
  value       = azurerm_lb_probe.this
}

output "backend_pools" {
  description = "contains load balancer backend pools"
  value       = azurerm_lb_backend_address_pool.this
}
