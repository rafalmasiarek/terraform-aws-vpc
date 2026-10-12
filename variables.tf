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

variable "use_tagger" {
  description = "Compute and apply standardized tags via terraform-null-tagger. When false, use var.tags as-is instead."
  type        = bool
  default     = true
}

variable "tagger_context" {
  description = "module.tagger.context from the root stack's base terraform-null-tagger call."
  type        = any
  default     = null
}

variable "tags" {
  description = "When use_tagger = true, fills in keys the tagger module doesn't already produce (tagger wins on conflict). Used as-is when use_tagger = false."
  type        = map(string)
  default     = {}
}
