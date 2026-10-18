locals {
  _has_igw  = !var.ipv6_only
  _has_eigw = var.enable_ipv6 || var.ipv6_only

  taggable = merge(
    {
      this = {
        name       = var.name
        service    = { network = { cidr_block = var.cidr_block } }
        attributes = []
        created_at = null
        extra_tags = {}
      }
    },
    local._has_igw ? {
      igw = {
        name       = "${var.name}-igw"
        service    = { network = { type = "internet-gateway" } }
        attributes = []
        created_at = null
        extra_tags = {}
      }
    } : {},
    local._has_eigw ? {
      eigw = {
        name       = "${var.name}-eigw"
        service    = { network = { type = "egress-only-internet-gateway" } }
        attributes = []
        created_at = null
        extra_tags = {}
      }
    } : {},
    var.enable_flow_logs ? {
      "flow-log" = {
        name       = local.flow_log_name
        service    = {}
        attributes = []
        created_at = null
        extra_tags = {}
      }
    } : {},
    var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? {
      "flow-log-role" = {
        name       = "${var.name}-flow-log-role"
        service    = {}
        attributes = []
        created_at = null
        extra_tags = {}
      }
    } : {}
  )

  assign_generated_ipv6_cidr_block = var.enable_ipv6 && var.ipv6_cidr_block == null && var.ipv6_ipam_pool_id == null

  flow_log_name = "${var.name}-flow-log"
}

resource "aws_vpc" "this" {
  count = var.ipv6_only ? 0 : 1

  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  assign_generated_ipv6_cidr_block = local.assign_generated_ipv6_cidr_block
  ipv6_cidr_block                  = var.ipv6_cidr_block
  ipv6_ipam_pool_id                = var.ipv6_ipam_pool_id

  tags = local.tagger_tags["this"]

}

# IPv6-only VPC: created without an IPv4 CIDR, with a generated IPv6 block.
resource "aws_vpc" "ipv6_only" {
  count = var.ipv6_only ? 1 : 0

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  assign_generated_ipv6_cidr_block = true

  tags = local.tagger_tags["this"]
}

locals {
  vpc_id = var.ipv6_only ? aws_vpc.ipv6_only[0].id : aws_vpc.this[0].id
}

resource "aws_internet_gateway" "this" {
  count = var.ipv6_only ? 0 : 1

  vpc_id = local.vpc_id

  tags = local.tagger_tags["igw"]
}

resource "aws_egress_only_internet_gateway" "this" {
  count  = (var.enable_ipv6 || var.ipv6_only) ? 1 : 0
  vpc_id = local.vpc_id

  tags = local.tagger_tags["eigw"]
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = toset(var.additional_ipv4_cidr_blocks)

  vpc_id     = local.vpc_id
  cidr_block = each.value
}

resource "aws_default_security_group" "this" {
  count = var.restrict_default_security_group ? 1 : 0

  vpc_id = local.vpc_id

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

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

# --- Flow Logs ---

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = "/vpc/${local.flow_log_name}"
  retention_in_days = var.flow_log_log_group_retention_days
  kms_key_id        = var.flow_log_log_group_kms_key_id

  tags = merge(local.tagger_tags["flow-log"], var.flow_log_tags)
}

data "aws_iam_policy_document" "flow_log_assume_role" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_log_cw" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [aws_cloudwatch_log_group.flow_log[0].arn]
  }
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name               = "${var.name}-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume_role[0].json

  tags = local.tagger_tags["flow-log-role"]
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  role   = aws_iam_role.flow_log[0].id
  name   = "${var.name}-flow-log-policy"
  policy = data.aws_iam_policy_document.flow_log_cw[0].json
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id                   = local.vpc_id
  log_destination_type     = var.flow_log_destination_type
  log_destination          = var.flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_log[0].arn : var.flow_log_destination_arn
  iam_role_arn             = var.flow_log_destination_type == "cloud-watch-logs" ? aws_iam_role.flow_log[0].arn : null
  traffic_type             = var.flow_log_traffic_type
  max_aggregation_interval = 60

  tags = merge(local.tagger_tags["flow-log"], var.flow_log_tags)
}
