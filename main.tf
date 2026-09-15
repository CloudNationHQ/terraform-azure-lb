# load balancer
resource "azurerm_lb" "this" {
  resource_group_name = coalesce(
    var.loadbalancer.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.loadbalancer.location, var.location
  )

  name      = var.loadbalancer.name
  sku       = var.loadbalancer.sku
  sku_tier  = var.loadbalancer.sku_tier
  edge_zone = var.loadbalancer.edge_zone

  tags = coalesce(
    var.loadbalancer.tags, var.tags
  )

  dynamic "frontend_ip_configuration" {
    for_each = var.loadbalancer.frontend_ip_configurations

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
resource "azurerm_lb_backend_address_pool" "this" {
  for_each = var.loadbalancer.backend_pools

  name = coalesce(
    each.value.name, each.key
  )

  loadbalancer_id    = azurerm_lb.this.id
  virtual_network_id = each.value.virtual_network_id
  synchronous_mode   = each.value.synchronous_mode

  dynamic "tunnel_interface" {
    for_each = each.value.tunnel_interfaces

    content {
      identifier = tunnel_interface.value.identifier
      type       = tunnel_interface.value.type
      protocol   = tunnel_interface.value.protocol
      port       = tunnel_interface.value.port
    }
  }
}

# backend pool addresses
resource "azurerm_lb_backend_address_pool_address" "this" {
  for_each = {
    for item in flatten([
      for pool_key, pool in var.loadbalancer.backend_pools : [
        for addr_key, addr in pool.addresses : {
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
  backend_address_pool_id             = azurerm_lb_backend_address_pool.this[each.value.pool_key].id
  backend_address_ip_configuration_id = each.value.backend_address_ip_configuration_id
  virtual_network_id                  = each.value.virtual_network_id
  ip_address                          = each.value.ip_address

  # the provider locks this resource on the pool name, every other lb child
  # resource locks on the lb id, so they can hit ARM concurrently and return
  # 409 AnotherOperationInProgress.
  depends_on = [
    azurerm_lb_nat_pool.this,
    azurerm_lb_nat_rule.this,
    azurerm_lb_probe.this,
    azurerm_lb_rule.this,
    azurerm_lb_outbound_rule.this,
  ]
}

# nat pools
resource "azurerm_lb_nat_pool" "this" {
  for_each = {
    for item in flatten([
      for frontend_key, frontend in var.loadbalancer.frontend_ip_configurations : [
        for pool_key, pool in frontend.nat_pools : {
          key = "${frontend_key}-${pool_key}"
          value = merge(pool, {
            frontend_key = frontend_key,
            pool_key     = pool_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  resource_group_name            = azurerm_lb.this.resource_group_name
  loadbalancer_id                = azurerm_lb.this.id
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
resource "azurerm_lb_nat_rule" "this" {
  for_each = {
    for item in flatten([
      for frontend_key, frontend in var.loadbalancer.frontend_ip_configurations : [
        for rule_key, rule in frontend.nat_rules : {
          key = "${frontend_key}-${rule_key}"
          value = merge(rule, {
            frontend_key = frontend_key,
            rule_key     = rule_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  resource_group_name            = azurerm_lb.this.resource_group_name
  loadbalancer_id                = azurerm_lb.this.id
  name                           = each.value.rule_key
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_key
  tcp_reset_enabled              = each.value.tcp_reset_enabled
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  floating_ip_enabled            = each.value.floating_ip_enabled
  frontend_port_start            = each.value.frontend_port_start
  frontend_port_end              = each.value.frontend_port_end
  backend_address_pool_id        = each.value.backend_address_pool_key != null ? azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_key].id : each.value.backend_address_pool_id
}

# probes
resource "azurerm_lb_probe" "this" {
  for_each = {
    for item in flatten([
      for pool_key, pool in var.loadbalancer.backend_pools : [
        for rule_key, rule in pool.rules : {
          key = "${pool_key}-${rule_key}"
          value = merge(rule.probe, {
            name     = "${pool_key}-${rule_key}",
            pool_key = pool_key,
            rule_key = rule_key,
          })
        }
        if rule.probe != null
      ]
    ]) :
    item.key => item.value
  }

  name                         = each.value.name
  loadbalancer_id              = azurerm_lb.this.id
  port                         = each.value.port
  protocol                     = each.value.protocol
  request_path                 = each.value.request_path
  interval_in_seconds          = each.value.interval_in_seconds
  number_of_probes             = each.value.number_of_probes
  probe_threshold              = each.value.probe_threshold
  no_healthy_backends_behavior = each.value.no_healthy_backends_behavior
}

# rules
resource "azurerm_lb_rule" "this" {
  for_each = {
    for item in flatten([
      for pool_key, pool in var.loadbalancer.backend_pools : [
        for rule_key, rule in pool.rules : {
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
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.pool_key].id]
  probe_id                       = each.value.probe != null ? azurerm_lb_probe.this[each.key].id : null
  floating_ip_enabled            = each.value.floating_ip_enabled
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  load_distribution              = each.value.load_distribution
  disable_outbound_snat          = each.value.disable_outbound_snat
  tcp_reset_enabled              = each.value.tcp_reset_enabled
}

# outbound rules
resource "azurerm_lb_outbound_rule" "this" {
  for_each = {
    for item in flatten([
      for pool_key, pool in var.loadbalancer.backend_pools : [
        for outbound_rule_key, outbound_rule in pool.outbound_rules : {
          key = "${pool_key}-${outbound_rule_key}"
          value = merge(outbound_rule, {
            pool_key          = pool_key,
            outbound_rule_key = outbound_rule_key,
          })
        }
      ]
    ]) : item.key => item.value
  }

  loadbalancer_id          = azurerm_lb.this.id
  name                     = each.value.outbound_rule_key
  protocol                 = each.value.protocol
  backend_address_pool_id  = azurerm_lb_backend_address_pool.this[each.value.pool_key].id
  allocated_outbound_ports = each.value.allocated_outbound_ports
  tcp_reset_enabled        = each.value.tcp_reset_enabled
  idle_timeout_in_minutes  = each.value.idle_timeout_in_minutes

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations

    content {
      name = frontend_ip_configuration.value
    }
  }
}
