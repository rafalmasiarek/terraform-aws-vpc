# terraform-aws-vpc
## About

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


## Terraform Reference



### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_tagger"></a> [tagger](#requirement\_tagger) | >= 0.1.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tagger"></a> [tagger](#module\_tagger) | rafalmasiarek/tagger/null | >= 0.5.0 |

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_egress_only_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_vpc.ipv6_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_ipv4_cidr_block_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [aws_iam_policy_document.flow_log_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_log_cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| tagger_origin.self | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ipv4_cidr_blocks"></a> [additional\_ipv4\_cidr\_blocks](#input\_additional\_ipv4\_cidr\_blocks) | Secondary IPv4 CIDR blocks to associate with the VPC. | `list(string)` | `[]` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | IPv4 CIDR block for the VPC. Required unless ipv6\_only = true. | `string` | n/a | yes |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | n/a | `string` | `null` | no |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp\_options\_domain\_name\_servers](#input\_dhcp\_options\_domain\_name\_servers) | n/a | `list(string)` | <pre>[<br/>  "AmazonProvidedDNS"<br/>]</pre> | no |
| <a name="input_dhcp_options_ntp_servers"></a> [dhcp\_options\_ntp\_servers](#input\_dhcp\_options\_ntp\_servers) | n/a | `list(string)` | `[]` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Create and associate a custom DHCP options set instead of using the VPC's own AWS-managed default. | `bool` | `false` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | n/a | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | n/a | `bool` | `true` | no |
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | Create a VPC Flow Log to CloudWatch Logs. | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Associate an IPv6 CIDR block with the VPC and create an Egress-Only Internet Gateway for private-subnet IPv6 egress. NAT Gateway does not carry IPv6 traffic at all - this is the separate mechanism AWS requires for it. | `bool` | `false` | no |
| <a name="input_flow_log_destination_arn"></a> [flow\_log\_destination\_arn](#input\_flow\_log\_destination\_arn) | S3 bucket ARN when flow\_log\_destination\_type = "s3". Ignored for cloud-watch-logs (log group is created automatically). The caller must add a bucket policy granting delivery.logs.amazonaws.com. | `string` | `null` | no |
| <a name="input_flow_log_destination_type"></a> [flow\_log\_destination\_type](#input\_flow\_log\_destination\_type) | "cloud-watch-logs" or "s3". | `string` | `"cloud-watch-logs"` | no |
| <a name="input_flow_log_log_group_kms_key_id"></a> [flow\_log\_log\_group\_kms\_key\_id](#input\_flow\_log\_log\_group\_kms\_key\_id) | KMS key for the Flow Log log group. Null = service-managed key. | `string` | `null` | no |
| <a name="input_flow_log_log_group_retention_days"></a> [flow\_log\_log\_group\_retention\_days](#input\_flow\_log\_log\_group\_retention\_days) | CloudWatch Logs retention in days. Only used when destination is cloud-watch-logs. | `number` | `90` | no |
| <a name="input_flow_log_tags"></a> [flow\_log\_tags](#input\_flow\_log\_tags) | Extra tags on the Flow Log resource and its IAM role / log group. | `map(string)` | `{}` | no |
| <a name="input_flow_log_traffic_type"></a> [flow\_log\_traffic\_type](#input\_flow\_log\_traffic\_type) | "ALL" or "REJECT". | `string` | `"ALL"` | no |
| <a name="input_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#input\_ipv6\_cidr\_block) | Bring your own /56 IPv6 CIDR block instead of an Amazon-provided one. Ignored unless enable\_ipv6 = true. | `string` | `null` | no |
| <a name="input_ipv6_ipam_pool_id"></a> [ipv6\_ipam\_pool\_id](#input\_ipv6\_ipam\_pool\_id) | IPAM pool to allocate the IPv6 CIDR from, instead of an Amazon-provided one. Ignored unless enable\_ipv6 = true. | `string` | `null` | no |
| <a name="input_ipv6_only"></a> [ipv6\_only](#input\_ipv6\_only) | IPv6-only VPC: no IPv4 CIDR block, no IGW, only EIGW. Set cidr\_block to null when true. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the VPC, used for the Name tag and as the tagger name. | `string` | n/a | yes |
| <a name="input_restrict_default_security_group"></a> [restrict\_default\_security\_group](#input\_restrict\_default\_security\_group) | Remove every ingress/egress rule from the VPC's default security group (AWS security best practice - every ENI without an explicit security group falls back to this one). Defaults to false because it changes real traffic behavior for anything already relying on the default security group's rules. | `bool` | `false` | no |
| <a name="input_tagger_additional_services"></a> [tagger\_additional\_services](#input\_tagger\_additional\_services) | Extra terraform-null-tagger `service` data per taggable resource, keyed by the same key as local.taggable (e.g. "subnet-public-a"). Merged on top of what this module computes automatically - lets a caller tag something this module doesn't know about, without waiting for a new module release. | `any` | `{}` | no |
| <a name="input_tagger_context"></a> [tagger\_context](#input\_tagger\_context) | module.tagger.context from the root stack's base terraform-null-tagger call. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the resource(s). | `map(string)` | `{}` | no |
| <a name="input_use_tagger"></a> [use\_tagger](#input\_use\_tagger) | Compute and apply standardized tags via terraform-null-tagger. When false, use var.tags as-is instead. | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_ipv4_cidr_block_associations"></a> [additional\_ipv4\_cidr\_block\_associations](#output\_additional\_ipv4\_cidr\_block\_associations) | Association ID per CIDR in additional\_ipv4\_cidr\_blocks, keyed by the CIDR itself. |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | n/a |
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | n/a |
| <a name="output_egress_only_internet_gateway_id"></a> [egress\_only\_internet\_gateway\_id](#output\_egress\_only\_internet\_gateway\_id) | n/a |
| <a name="output_flow_log_iam_role_arn"></a> [flow\_log\_iam\_role\_arn](#output\_flow\_log\_iam\_role\_arn) | n/a |
| <a name="output_flow_log_id"></a> [flow\_log\_id](#output\_flow\_log\_id) | n/a |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | n/a |
| <a name="output_ipv6_cidr_block"></a> [ipv6\_cidr\_block](#output\_ipv6\_cidr\_block) | n/a |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```text
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to deal in the Software
without restriction.

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

Source: https://opensource.org/licenses/MIT
```


See [LICENSE](LICENSE) for full details.
## Authors

- Rafał Masiarek | [website](https://masiarek.pl) | [email](mailto:rafal@masiarek.pl) | [github](https://github.com/rafalmasiarek)


<!-- references -->

[repo_link]: https://github.com/rafalmasiarek/terraform-aws-vpc
