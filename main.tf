locals {
  taggable = { this = { name = var.name } }

  # AWS rejects assign_generated_ipv6_cidr_block = true alongside an
  # explicit ipv6_cidr_block or ipv6_ipam_pool_id - only auto-generate
  # when the caller didn't bring their own.
  assign_generated_ipv6_cidr_block = var.enable_ipv6 && var.ipv6_cidr_block == null && var.ipv6_ipam_pool_id == null
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  assign_generated_ipv6_cidr_block = local.assign_generated_ipv6_cidr_block
  ipv6_cidr_block                  = var.ipv6_cidr_block
  ipv6_ipam_pool_id                = var.ipv6_ipam_pool_id

  tags = local.tagger_tags["this"]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tagger_tags["this"], { Name = "${var.name}-igw" })
}

# Separate from NAT Gateway on purpose - NAT Gateway does not carry IPv6
# traffic. This is the only AWS mechanism for private-subnet IPv6 egress.
resource "aws_egress_only_internet_gateway" "this" {
  count  = var.enable_ipv6 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.tagger_tags["this"], { Name = "${var.name}-eigw" })
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = toset(var.additional_ipv4_cidr_blocks)

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
}

# No ingress/egress blocks below = every rule removed from the default
# security group, per AWS's own hardening recommendation.
resource "aws_default_security_group" "this" {
  count = var.restrict_default_security_group ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.tagger_tags["this"], { Name = "${var.name}-default-sg-restricted" })
}

resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name         = var.dhcp_options_domain_name
  domain_name_servers = var.dhcp_options_domain_name_servers
  ntp_servers         = var.dhcp_options_ntp_servers

  tags = merge(local.tagger_tags["this"], { Name = "${var.name}-dhcp-options" })
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}
