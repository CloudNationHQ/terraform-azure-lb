# Gateway Load Balancer

This deploys a gateway load balancer

## Types

```hcl
config = object({
  name           = string
  location       = string
  resource_group = string
  sku            = string
  frontend_ip_configurations = optional(map(object({
    subnet_id = string
  })))
  backend_pools = optional(map(object({
    virtual_network_id = string
    tunnel_interfaces = optional(map(object({
      identifier = string
      type       = string
      protocol   = string
      port       = number
    })))
  })))
})
```
