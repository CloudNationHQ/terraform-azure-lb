# load balancer
resource "azurerm_lb" "lb" {
  name                = var.config.name
  resource_group_name = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  location            = coalesce(lookup(var.config, "location", null), var.location)
  sku                 = try(var.config.sku, "Standard")
  sku_tier            = try(var.config.sku_tier, "Regional")
  edge_zone           = try(var.config.edge_zone, null)
  tags                = try(var.config.tags, var.tags)

  dynamic "frontend_ip_configuration" {
    for_each = lookup(
      var.config, "frontend_ip_configurations", {}
    )

    content {
      name                                               = frontend_ip_configuration.key
      zones                                              = try(frontend_ip_configuration.value.zones, null)
      subnet_id                                          = try(frontend_ip_configuration.value.subnet_id, null)
      private_ip_address_allocation                      = try(frontend_ip_configuration.value.private_ip_address_allocation, "Dynamic")
      public_ip_prefix_id                                = try(frontend_ip_configuration.value.public_ip_prefix_id, null)
      private_ip_address_version                         = try(frontend_ip_configuration.value.private_ip_address_version, null)
      private_ip_address                                 = try(frontend_ip_configuration.value.private_ip_address, null)
      public_ip_address_id                               = try(frontend_ip_configuration.value.public_ip_address_id, null)
      gateway_load_balancer_frontend_ip_configuration_id = try(frontend_ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id, null)
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
  virtual_network_id = try(each.value.virtual_network_id, null)
  synchronous_mode   = try(each.value.synchronous_mode, null)

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

  name                    = each.value.addr_key
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools[each.value.pool_key].id

  backend_address_ip_configuration_id = try(
    each.value.backend_address_ip_configuration_id, null
  )

  virtual_network_id = contains(keys(each.value), "backend_address_ip_configuration_id") ? null : try(each.value.virtual_network_id, null)
  ip_address         = contains(keys(each.value), "backend_address_ip_configuration_id") ? null : try(each.value.ip_address, null)
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
  protocol            = try(each.value.protocol, null)
  request_path        = try(each.value.request_path, null)
  interval_in_seconds = try(each.value.interval_in_seconds, null)
  number_of_probes    = try(each.value.number_of_probes, null)
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
  enable_floating_ip             = try(each.value.enable_floating_ip, null)
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, null)
  load_distribution              = try(each.value.load_distribution, null)
  disable_outbound_snat          = try(each.value.disable_outbound_snat, true)
  enable_tcp_reset               = try(each.value.enable_tcp_reset, null)
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
  allocated_outbound_ports = try(each.value.allocated_outbound_ports, null)
  enable_tcp_reset         = try(each.value.enable_tcp_reset, null)
  idle_timeout_in_minutes  = try(each.value.idle_timeout_in_minutes, null)

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations

    content {
      name = frontend_ip_configuration.value
    }
  }
}
