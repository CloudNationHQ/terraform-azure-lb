# Load Balancer

This terraform module simplifies the setup and management of azure load balancers, providing flexible frontend and backend configurations for optimized traffic distribution and network efficiency.

## Features

Utilization of terratest for robust validation.

Enables multiple backend pools and address configurations.

Allows multiple IP configurations on frontend endpoints.

Multiple load balancing rules and probes per backend pool.

Multiple outbound rules per backend pool.

Supports multiple nat pools.

Enables creation of multiple nat rules.

Multiple tunnel interfaces on backend pools on gateway load balancers.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_lb.lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) (resource)
- [azurerm_lb_backend_address_pool.pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) (resource)
- [azurerm_lb_backend_address_pool_address.pool_addresses](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) (resource)
- [azurerm_lb_nat_pool.nat_pools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_pool) (resource)
- [azurerm_lb_nat_rule.nat_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_rule) (resource)
- [azurerm_lb_outbound_rule.outbound_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_outbound_rule) (resource)
- [azurerm_lb_probe.probes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) (resource)
- [azurerm_lb_rule.rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: Contains all load balancer configuration

Type:

```hcl
object({
    name           = string
    resource_group = optional(string, null)
    location       = optional(string, null)
    sku            = optional(string, "Standard")
    sku_tier       = optional(string, "Regional")
    edge_zone      = optional(string, null)
    tags           = optional(map(string), null)
    frontend_ip_configurations = optional(map(object({
      zones                                              = optional(list(string), null)
      subnet_id                                          = optional(string, null)
      private_ip_address_allocation                      = optional(string, "Dynamic")
      public_ip_prefix_id                                = optional(string, null)
      private_ip_address_version                         = optional(string, null)
      private_ip_address                                 = optional(string, null)
      public_ip_address_id                               = optional(string, null)
      gateway_load_balancer_frontend_ip_configuration_id = optional(string, null)
      nat_pools = optional(map(object({
        protocol                = string
        frontend_port_start     = number
        frontend_port_end       = number
        backend_port            = number
        tcp_reset_enabled       = optional(bool, null)
        floating_ip_enabled     = optional(bool, null)
        idle_timeout_in_minutes = optional(number, 4)
      })), {})
      nat_rules = optional(map(object({
        protocol                = string
        frontend_port           = number
        backend_port            = number
        enable_tcp_reset        = optional(bool, null)
        idle_timeout_in_minutes = optional(number, null)
        enable_floating_ip      = optional(bool, false)
        frontend_port_start     = optional(number, null)
        frontend_port_end       = optional(number, null)
        backend_address_pool_id = optional(string, null)
      })), {})
    })), {})
    backend_pools = optional(map(object({
      virtual_network_id = optional(string, null)
      synchronous_mode   = optional(bool, null)
      tunnel_interfaces = optional(map(object({
        identifier = string
        type       = string
        protocol   = string
        port       = number
      })), {})
      addresses = optional(map(object({
        backend_address_ip_configuration_id = optional(string, null)
        virtual_network_id                  = optional(string, null)
        ip_address                          = optional(string, null)
      })), {})
      rules = optional(map(object({
        protocol                       = string
        frontend_port                  = number
        backend_port                   = number
        frontend_ip_configuration_name = string
        enable_floating_ip             = optional(bool, null)
        idle_timeout_in_minutes        = optional(number, null)
        load_distribution              = optional(string, null)
        disable_outbound_snat          = optional(bool, true)
        enable_tcp_reset               = optional(bool, null)
        probe = optional(object({
          port                = number
          protocol            = optional(string, null)
          request_path        = optional(string, null)
          interval_in_seconds = optional(number, null)
          number_of_probes    = optional(number, null)
          probe_threshold     = optional(number, 1)
        }), null)
      })), {})
      outbound_rules = optional(map(object({
        protocol                   = string
        allocated_outbound_ports   = optional(number, null)
        enable_tcp_reset           = optional(bool, null)
        idle_timeout_in_minutes    = optional(number, null)
        frontend_ip_configurations = list(string)
      })), {})
    })), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_backend_pools"></a> [backend\_pools](#output\_backend\_pools)

Description: contains load balancer backend pools

### <a name="output_config"></a> [config](#output\_config)

Description: contains load balancer configuration

### <a name="output_nat_pools"></a> [nat\_pools](#output\_nat\_pools)

Description: contains load balancer nat pools

### <a name="output_nat_rules"></a> [nat\_rules](#output\_nat\_rules)

Description: contains load balancer nat rules

### <a name="output_probes"></a> [probes](#output\_probes)

Description: contains load balancer probes

### <a name="output_rules"></a> [rules](#output\_rules)

Description: contains load balancer rules
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-lb/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-lb" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/load-balancer/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/load-balancer/)
- [Rest Api Specs](https://github.com/hashicorp/pandora/tree/main/api-definitions/resource-manager/Network/2024-03-01/LoadBalancers)
