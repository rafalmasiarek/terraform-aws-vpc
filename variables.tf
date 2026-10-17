variable "name" {
  description = "Name of the VPC, used for the Name tag and as the tagger name."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the VPC. Required unless ipv6_only = true."
  type        = string

  validation {
    condition     = var.cidr_block == null || can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR (e.g. 10.0.0.0/16)."
  }
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_ipv6" {
  description = "Associate an IPv6 CIDR block with the VPC and create an Egress-Only Internet Gateway for private-subnet IPv6 egress. NAT Gateway does not carry IPv6 traffic at all - this is the separate mechanism AWS requires for it."
  type        = bool
  default     = false
}

variable "ipv6_cidr_block" {
  description = "Bring your own /56 IPv6 CIDR block instead of an Amazon-provided one. Ignored unless enable_ipv6 = true."
  type        = string
  default     = null
}

variable "ipv6_ipam_pool_id" {
  description = "IPAM pool to allocate the IPv6 CIDR from, instead of an Amazon-provided one. Ignored unless enable_ipv6 = true."
  type        = string
  default     = null
}

variable "additional_ipv4_cidr_blocks" {
  description = "Secondary IPv4 CIDR blocks to associate with the VPC."
  type        = list(string)
  default     = []
}

variable "restrict_default_security_group" {
  description = "Remove every ingress/egress rule from the VPC's default security group (AWS security best practice - every ENI without an explicit security group falls back to this one). Defaults to false because it changes real traffic behavior for anything already relying on the default security group's rules."
  type        = bool
  default     = false
}

variable "enable_dhcp_options" {
  description = "Create and associate a custom DHCP options set instead of using the VPC's own AWS-managed default."
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  type    = string
  default = null
}

variable "dhcp_options_domain_name_servers" {
  type    = list(string)
  default = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  type    = list(string)
  default = []
}

# --- Flow Logs ---

variable "enable_flow_logs" {
  description = "Create a VPC Flow Log to CloudWatch Logs."
  type        = bool
  default     = false
}

variable "flow_log_destination_type" {
  description = "\"cloudwatch-logs\" or \"s3\"."
  type        = string
  default     = "cloudwatch-logs"
}

variable "flow_log_destination_arn" {
  description = "S3 bucket ARN when flow_log_destination_type = \"s3\". Ignored for cloudwatch-logs (log group is created automatically)."
  type        = string
  default     = null
}

variable "flow_log_traffic_type" {
  description = "\"ALL\" or \"REJECT\"."
  type        = string
  default     = "ALL"
}

variable "flow_log_log_group_retention_days" {
  description = "CloudWatch Logs retention in days. Only used when destination is cloudwatch-logs."
  type        = number
  default     = 90
}

variable "flow_log_log_group_kms_key_id" {
  description = "KMS key for the Flow Log log group. Null = service-managed key."
  type        = string
  default     = null
}

variable "flow_log_tags" {
  description = "Extra tags on the Flow Log resource and its IAM role / log group."
  type        = map(string)
  default     = {}
}

# --- IPv6 validation ---

variable "ipv6_only" {
  description = "IPv6-only VPC: no IPv4 CIDR block, no IGW, only EIGW. Set cidr_block to null when true."
  type        = bool
  default     = false

  validation {
    condition     = !var.ipv6_only || var.cidr_block == null
    error_message = "ipv6_only = true requires cidr_block = null."
  }
  validation {
    condition     = !(var.ipv6_only && var.enable_ipv6)
    error_message = "ipv6_only and enable_ipv6 are mutually exclusive."
  }
}
