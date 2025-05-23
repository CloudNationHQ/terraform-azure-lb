# load balancer
resource "azurerm_lb" "lb" {
  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  name      = var.config.name
  sku       = var.config.sku
  sku_tier  = var.config.sku_tier
  edge_zone = var.config.edge_zone

  tags = coalesce(
    var.config.tags, var.tags
  )

  dynamic "frontend_ip_configuration" {
    for_each = lookup(
      var.config, "frontend_ip_configurations", {}
    )

    content {
      name                                               = frontend_ip_configuration.key
      zones                                              = frontend_ip_configuration.value.zones
      subnet_id                                          = frontend_ip_configuration.value.subnet_id
      private_ip_address_allocation                      = frontend_ip_configuration.value.private_ip_address_allocation
      public_ip_prefix_id                                = frontend_ip_configuration.value.public_ip_prefix_id
      private_ip_address_version                         = frontend_ip_configuration.value.private_ip_address_version
      private_ip_address                                 = frontend_ip_configuration.value.private_ip_address
      public_ip_address_id                               = frontend_ip_configuration.value.public_ip_address_id
      gateway_load_balancer_frontend_ip_configuration_id = frontend_ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id
    }
  }
}

# backend pools
resource "azurerm_lb_backend_address_pool" "pools" {
  for_each = lookup(
    var.config, "backend_pools", {}
  )

  name               = each.key
  loadbalancer_id    = azurerm_lb.lb.id
  virtual_network_id = each.value.virtual_network_id
  synchronous_mode   = each.value.synchronous_mode

  dynamic "tunnel_interface" {
    for_each = lookup(each.value, "tunnel_interfaces", {})
    content {
      identifier = tunnel_interface.value.identifier
      type       = tunnel_interface.value.type
      protocol   = tunnel_interface.value.protocol
      port       = tunnel_interface.value.port
    }
  }
}

# backend pool addresses
resource "azurerm_lb_backend_address_pool_address" "pool_addresses" {
  for_each = {
    for item in flatten([
      for pool_key, pool in lookup(var.config, "backend_pools", {}) : [
        for addr_key, addr in lookup(pool, "addresses", {}) : {
          key = "${pool_key}-${addr_key}"
          value = merge(addr, {
            pool_key = pool_key,
            addr_key = addr_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  name                                = each.value.addr_key
  backend_address_pool_id             = azurerm_lb_backend_address_pool.pools[each.value.pool_key].id
  backend_address_ip_configuration_id = each.value.backend_address_ip_configuration_id
  virtual_network_id                  = each.value.virtual_network_id
  ip_address                          = each.value.ip_address
}

# nat pools
resource "azurerm_lb_nat_pool" "nat_pools" {
  for_each = {
    for item in flatten([
      for frontend_key, frontend in lookup(var.config, "frontend_ip_configurations", {}) : [
        for pool_key, pool in lookup(frontend, "nat_pools", {}) : {
          key = "${frontend_key}-${pool_key}"
          value = merge(pool, {
            frontend_key = frontend_key,
            pool_key     = pool_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  resource_group_name            = azurerm_lb.lb.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.value.pool_key
  protocol                       = each.value.protocol
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_key
  tcp_reset_enabled              = each.value.tcp_reset_enabled
  floating_ip_enabled            = each.value.floating_ip_enabled
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
}

# nat rules
resource "azurerm_lb_nat_rule" "nat_rules" {
  for_each = {
    for item in flatten([
      for frontend_key, frontend in lookup(var.config, "frontend_ip_configurations", {}) : [
        for rule_key, rule in lookup(frontend, "nat_rules", {}) : {
          key = "${frontend_key}-${rule_key}"
          value = merge(rule, {
            frontend_key = frontend_key,
            rule_key     = rule_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  resource_group_name            = azurerm_lb.lb.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.value.rule_key
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_key
  enable_tcp_reset               = each.value.enable_tcp_reset
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  enable_floating_ip             = each.value.enable_floating_ip
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_address_pool_id        = each.value.backend_address_pool_id
}

# probes
resource "azurerm_lb_probe" "probes" {
  for_each = {
    for item in flatten([
      for pool_key, pool in lookup(var.config, "backend_pools", {}) : [
        for rule_key, rule in lookup(pool, "rules", {}) : {
          key = "${pool_key}-${rule_key}"
          value = merge(rule.probe, {
            name     = "${pool_key}-${rule_key}",
            pool_key = pool_key,
            rule_key = rule_key,
          })
        }
        if lookup(rule, "probe", null) != null
      ]
    ]) :
    item.key => item.value
  }

  name                = each.value.name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = each.value.port
  protocol            = each.value.protocol
  request_path        = each.value.request_path
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
  probe_threshold     = each.value.probe_threshold
}

# rules
resource "azurerm_lb_rule" "rules" {
  for_each = {
    for item in flatten([
      for pool_key, pool in lookup(var.config, "backend_pools", {}) : [
        for rule_key, rule in lookup(pool, "rules", {}) : {
          key = "${pool_key}-${rule_key}"
          value = merge(rule, {
            pool_key = pool_key,
            rule_key = rule_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  name                           = each.key
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pools[each.value.pool_key].id]
  probe_id                       = lookup(each.value, "probe", null) != null ? azurerm_lb_probe.probes[each.key].id : null
  enable_floating_ip             = each.value.enable_floating_ip
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  load_distribution              = each.value.load_distribution
  disable_outbound_snat          = each.value.disable_outbound_snat
  enable_tcp_reset               = each.value.enable_tcp_reset
}

# outbound rules
resource "azurerm_lb_outbound_rule" "outbound_rules" {
  for_each = {
    for item in flatten([
      for pool_key, pool in lookup(var.config, "backend_pools", {}) : [
        for outbound_rule_key, outbound_rule in lookup(pool, "outbound_rules", {}) : {
          key = "${pool_key}-${outbound_rule_key}"
          value = merge(outbound_rule, {
            pool_key          = pool_key,
            outbound_rule_key = outbound_rule_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  loadbalancer_id          = azurerm_lb.lb.id
  name                     = each.value.outbound_rule_key
  protocol                 = each.value.protocol
  backend_address_pool_id  = azurerm_lb_backend_address_pool.pools[each.value.pool_key].id
  allocated_outbound_ports = each.value.allocated_outbound_ports
  enable_tcp_reset         = each.value.enable_tcp_reset
  idle_timeout_in_minutes  = each.value.idle_timeout_in_minutes

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations

    content {
      name = frontend_ip_configuration.value
    }
  }
}
