output "config" {
  description = "contains load balancer configuration"
  value       = azurerm_lb.lb
}

output "rules" {
  description = "contains load balancer rules"
  value       = azurerm_lb_rule.rules
}

output "nat_pools" {
  description = "contains load balancer nat pools"
  value       = azurerm_lb_nat_pool.nat_pools
}

output "nat_rules" {
  description = "contains load balancer nat rules"
  value       = azurerm_lb_nat_rule.nat_rules
}

output "probes" {
  description = "contains load balancer probes"
  value       = azurerm_lb_probe.probes
}

output "backend_pools" {
  description = "contains load balancer backend pools"
  value       = azurerm_lb_backend_address_pool.pools
}
