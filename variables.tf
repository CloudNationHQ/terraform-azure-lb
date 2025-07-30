variable "config" {
  description = "Contains all load balancer configuration"
  type = object({
    name                = string
    resource_group_name = optional(string)
    location            = optional(string)
    sku                 = optional(string, "Standard")
    sku_tier            = optional(string, "Regional")
    edge_zone           = optional(string)
    tags                = optional(map(string))
    frontend_ip_configurations = optional(map(object({
      zones                                              = optional(set(string))
      subnet_id                                          = optional(string)
      private_ip_address_allocation                      = optional(string, "Dynamic")
      public_ip_prefix_id                                = optional(string)
      private_ip_address_version                         = optional(string, "IPv4")
      private_ip_address                                 = optional(string)
      public_ip_address_id                               = optional(string)
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
      nat_pools = optional(map(object({
        protocol                = string
        frontend_port_start     = number
        frontend_port_end       = number
        backend_port            = number
        tcp_reset_enabled       = optional(bool)
        floating_ip_enabled     = optional(bool)
        idle_timeout_in_minutes = optional(number, 4)
      })), {})
      nat_rules = optional(map(object({
        protocol                = string
        frontend_port           = number
        backend_port            = number
        enable_tcp_reset        = optional(bool)
        idle_timeout_in_minutes = optional(number)
        enable_floating_ip      = optional(bool)
        frontend_port_start     = optional(number)
        frontend_port_end       = optional(number)
        backend_address_pool_id = optional(string)
      })), {})
    })), {})
    backend_pools = optional(map(object({
      virtual_network_id = optional(string)
      synchronous_mode   = optional(string)
      tunnel_interfaces = optional(map(object({
        identifier = number
        type       = string
        protocol   = string
        port       = number
      })), {})
      addresses = optional(map(object({
        backend_address_ip_configuration_id = optional(string)
        virtual_network_id                  = optional(string)
        ip_address                          = optional(string)
      })), {})
      rules = optional(map(object({
        protocol                       = string
        frontend_port                  = number
        backend_port                   = number
        frontend_ip_configuration_name = string
        enable_floating_ip             = optional(bool)
        idle_timeout_in_minutes        = optional(number, 4)
        load_distribution              = optional(string, "Default")
        disable_outbound_snat          = optional(bool, true)
        enable_tcp_reset               = optional(bool)
        probe = optional(object({
          port                = number
          protocol            = optional(string)
          request_path        = optional(string)
          interval_in_seconds = optional(number, 15)
          number_of_probes    = optional(number, 2)
          probe_threshold     = optional(number, 1)
        }), null)
      })), {})
      outbound_rules = optional(map(object({
        protocol                   = string
        allocated_outbound_ports   = optional(number)
        enable_tcp_reset           = optional(bool)
        idle_timeout_in_minutes    = optional(number)
        frontend_ip_configurations = optional(list(string))
      })), {})
    })), {})
  })
  validation {
    condition     = var.config.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }

  validation {
    condition = alltrue([
      for config in var.config.frontend_ip_configurations :
      config.private_ip_address_allocation == "Static" ? config.private_ip_address != null : true
    ])
    error_message = "private_ip_address must be specified when private_ip_address_allocation is 'Static'."
  }

  validation {
    condition = alltrue(flatten([
      for frontend in var.config.frontend_ip_configurations : [
        for pool in frontend.nat_pools :
        pool.frontend_port_start <= pool.frontend_port_end
      ]
    ]))
    error_message = "NAT pool frontend_port_start must be less than or equal to frontend_port_end."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.config.backend_pools : [
        for rule in pool.rules :
        rule.probe != null && contains(["Http", "Https"], rule.probe.protocol) ? 
        rule.probe.request_path != null : true
      ]
    ]))
    error_message = "HTTP/HTTPS health probes must specify a request_path."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.config.backend_pools : [
        for rule in pool.rules :
        rule.probe != null ? rule.probe.interval_in_seconds >= 5 : true
      ]
    ]))
    error_message = "Health probe interval_in_seconds must be at least 5 seconds."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.config.backend_pools : [
        for rule in pool.rules :
        rule.probe != null ? (rule.probe.number_of_probes >= 1 && rule.probe.number_of_probes <= 100) : true
      ]
    ]))
    error_message = "Health probe number_of_probes must be between 1 and 100."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.config.backend_pools : [
        for tunnel in pool.tunnel_interfaces :
        tunnel.identifier >= 800 && tunnel.identifier <= 900
      ]
    ]))
    error_message = "Gateway load balancer tunnel interface identifier must be between 800 and 900."
  }

  validation {
    condition = alltrue(flatten([
      for pool in var.config.backend_pools : [
        for rule in pool.rules :
        contains(keys(var.config.frontend_ip_configurations), rule.frontend_ip_configuration_name)
      ]
    ]))
    error_message = "frontend_ip_configuration_name in rules must reference an existing frontend IP configuration key."
  }

  validation {
    condition = var.config.sku == "Gateway" ? length(var.config.frontend_ip_configurations) <= 1 : true
    error_message = "Gateway load balancers can only have one frontend IP configuration."
  }

  validation {
    condition = var.config.sku == "Basic" ? alltrue([
      for config in var.config.frontend_ip_configurations :
      config.zones == null || length(config.zones) == 0
    ]) : true
    error_message = "Basic SKU load balancers do not support availability zones."
  }

  validation {
    condition = !(var.config.sku == "Basic" && var.config.sku_tier == "Global")
    error_message = "Basic SKU does not support Global tier - use Standard or Gateway SKU for Global tier."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
