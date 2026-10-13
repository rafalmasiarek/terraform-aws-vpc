output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "ipv6_cidr_block" {
  value = var.enable_ipv6 ? aws_vpc.this.ipv6_cidr_block : null
}

output "egress_only_internet_gateway_id" {
  value = var.enable_ipv6 ? aws_egress_only_internet_gateway.this[0].id : null
}

output "default_security_group_id" {
  value = aws_vpc.this.default_security_group_id
}
