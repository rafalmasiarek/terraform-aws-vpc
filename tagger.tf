# terraform-null-tagger / terraform-provider-tagger wiring. See
# https://github.com/rafalmasiarek/terraform-null-tagger and
# https://github.com/rafalmasiarek/terraform-provider-tagger.
#
# use_tagger = false skips all of this and falls back to var.tags as-is -
# but the tagger provider must still be declared in required_providers
# regardless (Terraform validates provider availability at init time
# independently of count = 0).

data "tagger_origin" "self" {
  count       = var.use_tagger ? 1 : 0
  module_path = path.module
}

module "tagger" {
  count   = var.use_tagger ? 1 : 0
  source  = "git::https://github.com/rafalmasiarek/terraform-null-tagger.git?ref=v0.1.0"
  context = var.tagger_context
  name    = var.name

  origin_source  = data.tagger_origin.self[0].source
  origin_version = data.tagger_origin.self[0].version
}

locals {
  resolved_tags = var.use_tagger ? module.tagger[0].tags : var.tags
}
