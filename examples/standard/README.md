# Standard Load Balancer

This deploys a standard load balancer

## Types

```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  sku            = string
  frontend_ip_configurations = optional(map(object({
    public_ip_address_id = string
    nat_pools = optional(map(object({
      protocol            = string
      frontend_port_start = number
      frontend_port_end   = number
      backend_port        = number
    })))
    nat_rules = optional(map(object({
      protocol      = string
      frontend_port = number
      backend_port  = number
    })))
  })))
  backend_pools = optional(map(object({
    addresses = optional(map(object({
      virtual_network_id = string
      ip_address         = string
    })))
    rules = optional(map(object({
      protocol                       = string
      frontend_port                  = number
      backend_port                   = number
      frontend_ip_configuration_name = string
      disable_outbound_snat          = optional(bool)
      probe = optional(object({
        protocol     = string
        port         = number
        request_path = string
      }))
    })))
    outbound_rules = optional(map(object({
      protocol                   = string
      frontend_ip_configurations = list(string)
    })))
  })))
})
```
