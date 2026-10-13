variable "name" {
  description = "Name of the VPC, used for the Name tag and as the tagger name."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
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
