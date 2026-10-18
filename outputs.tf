output "vpc_id" {
  value = local.vpc_id
}

output "vpc_cidr_block" {
  value = var.ipv6_only ? null : aws_vpc.this[0].cidr_block
}

output "internet_gateway_id" {
  value = var.ipv6_only ? null : aws_internet_gateway.this[0].id
}

output "ipv6_cidr_block" {
  value = (var.enable_ipv6 || var.ipv6_only) ? (var.ipv6_only ? aws_vpc.ipv6_only[0].ipv6_cidr_block : aws_vpc.this[0].ipv6_cidr_block) : null
}

output "egress_only_internet_gateway_id" {
  value = (var.enable_ipv6 || var.ipv6_only) ? aws_egress_only_internet_gateway.this[0].id : null
}

output "default_security_group_id" {
  value = var.ipv6_only ? aws_vpc.ipv6_only[0].default_security_group_id : aws_vpc.this[0].default_security_group_id
}

output "flow_log_id" {
  value = var.enable_flow_logs ? aws_flow_log.this[0].id : null
}

output "flow_log_iam_role_arn" {
  value = var.enable_flow_logs ? aws_iam_role.flow_log[0].arn : null
}

output "dhcp_options_id" {
  value = var.enable_dhcp_options ? aws_vpc_dhcp_options.this[0].id : null
}
