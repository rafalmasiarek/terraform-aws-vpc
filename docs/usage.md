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


## External CIDR sources

Every CIDR-shaped input (`cidr_block`, `ipv6_cidr_block`,
`additional_ipv4_cidr_blocks`) is passed straight through to the
underlying AWS resources - this module never recalculates or slices
them itself. Any externally computed value works the same way a
literal string does:

```hcl
module "vpc" {
  source = "..."

  name       = "production"
  cidr_block = data.netutils_subnet_plan.main.base_cidr # or any other source
}
```

This module has no dependency on `netutils` or any other provider for
this - it's just an ordinary Terraform input.

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
