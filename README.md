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
| `use_tagger` | `bool` | `true` | `false` applies `var.tags` as-is instead. |
| `tagger_context` | `any` | `null` | `module.tagger.context` from the root stack. |
| `tags` | `map(string)` | `{}` | Fills gaps when `use_tagger = true` (tagger wins on conflict); used as-is when `false`. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | |
| `vpc_cidr_block` | |
| `internet_gateway_id` | |

## Tagging

Tags come from
[terraform-null-tagger](https://github.com/rafalmasiarek/terraform-null-tagger),
using this module's own origin (detected via
[terraform-provider-tagger](https://github.com/rafalmasiarek/terraform-provider-tagger))
merged with `var.tagger_context`.
