variable "loadbalancer" {
  description = "Contains all load balancer configuration"
  type = object({
    name                = string
    resource_group_name = optional(string)
    location            = optional(string)
    sku                 = optional(string)
    sku_tier            = optional(string)
    edge_zone           = optional(string)
    tags                = optional(map(string))
    frontend_ip_configurations = optional(map(object({
      zones                                              = optional(set(string))
      subnet_id                                          = optional(string)
      private_ip_address_allocation                      = optional(string)
      public_ip_prefix_id                                = optional(string)
      private_ip_address_version                         = optional(string)
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
        idle_timeout_in_minutes = optional(number)
      })), {})
      nat_rules = optional(map(object({
        protocol                 = string
        frontend_port            = optional(number)
        backend_port             = number
        tcp_reset_enabled        = optional(bool)
        idle_timeout_in_minutes  = optional(number)
        floating_ip_enabled      = optional(bool)
        frontend_port_start      = optional(number)
        frontend_port_end        = optional(number)
        backend_address_pool_id  = optional(string)
        backend_address_pool_key = optional(string)
      })), {})
    })), {})
    backend_pools = optional(map(object({
      name               = optional(string)
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
        floating_ip_enabled            = optional(bool)
        idle_timeout_in_minutes        = optional(number)
        load_distribution              = optional(string)
        disable_outbound_snat          = optional(bool, true)
        tcp_reset_enabled              = optional(bool)
        probe = optional(object({
          port                = number
          protocol            = optional(string)
          request_path        = optional(string)
          interval_in_seconds = optional(number, 15)
          number_of_probes    = optional(number)
          probe_threshold     = optional(number)
        }), null)
      })), {})
      outbound_rules = optional(map(object({
        protocol                   = string
        allocated_outbound_ports   = optional(number)
        tcp_reset_enabled          = optional(bool)
        idle_timeout_in_minutes    = optional(number)
        frontend_ip_configurations = optional(list(string), [])
      })), {})
    })), {})
  })
  validation {
    condition     = var.loadbalancer.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.loadbalancer.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
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
