# terraform-aws-vpc

Terraform module provisioning a VPC and Internet Gateway. Subnets, route
tables and NAT are separate concerns - see
[terraform-aws-subnets](https://github.com/rafalmasiarek/terraform-aws-subnets).

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/rafalmasiarek/terraform-aws-vpc.git?ref=v0.1.0"

  name       = "my-stack"
  cidr_block = "10.0.0.0/16"

  enable_ipv6 = true

  tagger_context = module.tagger.context
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | - | VPC name (Name tag, tagger name). |
| `cidr_block` | `string` | - | VPC IPv4 CIDR. |
| `enable_dns_support` | `bool` | `true` | |
| `enable_dns_hostnames` | `bool` | `true` | |
| `enable_ipv6` | `bool` | `false` | Associate an IPv6 CIDR and create an Egress-Only Internet Gateway for private IPv6 egress. |
| `ipv6_cidr_block` | `string` | `null` | Bring your own /56 instead of an Amazon-provided one. |
| `ipv6_ipam_pool_id` | `string` | `null` | Allocate the IPv6 CIDR from an IPAM pool instead. |
| `additional_ipv4_cidr_blocks` | `list(string)` | `[]` | Secondary IPv4 CIDR blocks to associate with the VPC. |
| `restrict_default_security_group` | `bool` | `false` | Remove every rule from the default security group (AWS hardening best practice - changes real traffic behavior). |
| `enable_dhcp_options` | `bool` | `false` | Create a custom DHCP options set instead of the AWS-managed default. |
| `dhcp_options_domain_name` | `string` | `null` | |
| `dhcp_options_domain_name_servers` | `list(string)` | `["AmazonProvidedDNS"]` | |
| `dhcp_options_ntp_servers` | `list(string)` | `[]` | |
| `use_tagger` | `bool` | `true` | `false` applies `var.tags` as-is instead. |
| `tagger_context` | `any` | `null` | `module.tagger.context` from the root stack. |
| `tags` | `map(string)` | `{}` | Custom tags for the resource. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | |
| `vpc_cidr_block` | |
| `internet_gateway_id` | |
| `ipv6_cidr_block` | `null` unless `enable_ipv6 = true`. |
| `egress_only_internet_gateway_id` | `null` unless `enable_ipv6 = true`. |
| `default_security_group_id` | Always set, regardless of `restrict_default_security_group`. |

## IPv6

NAT Gateway does not carry IPv6 traffic at all - AWS requires a separate
device, the Egress-Only Internet Gateway, for private-subnet outbound-only
IPv6. `enable_ipv6 = true` creates both the VPC's IPv6 CIDR association
and this gateway; wire its id into
[terraform-aws-subnets](https://github.com/rafalmasiarek/terraform-aws-subnets)'s
`egress_only_gateway_id` route target.

## Tagging

Tags come from
[terraform-null-tagger](https://github.com/rafalmasiarek/terraform-null-tagger),
using this module's own origin (detected via
[terraform-provider-tagger](https://github.com/rafalmasiarek/terraform-provider-tagger))
merged with `var.tagger_context`.
