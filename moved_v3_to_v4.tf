moved {
  from = azurerm_lb.lb
  to   = azurerm_lb.this
}

moved {
  from = azurerm_lb_backend_address_pool.pools
  to   = azurerm_lb_backend_address_pool.this
}

moved {
  from = azurerm_lb_backend_address_pool_address.pool_addresses
  to   = azurerm_lb_backend_address_pool_address.this
}

moved {
  from = azurerm_lb_nat_pool.nat_pools
  to   = azurerm_lb_nat_pool.this
}

moved {
  from = azurerm_lb_nat_rule.nat_rules
  to   = azurerm_lb_nat_rule.this
}

moved {
  from = azurerm_lb_probe.probes
  to   = azurerm_lb_probe.this
}

moved {
  from = azurerm_lb_rule.rules
  to   = azurerm_lb_rule.this
}

moved {
  from = azurerm_lb_outbound_rule.outbound_rules
  to   = azurerm_lb_outbound_rule.this
}
