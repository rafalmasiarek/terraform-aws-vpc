# terraform-null-tagger / terraform-provider-tagger wiring.
# use_tagger = false falls back to var.tags; provider is still required
# regardless (init validates it independently of count = 0).

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
  # var.tags fills in keys tagger doesn't already produce - tagger's own
  # tags always win on conflict.
  resolved_tags = var.use_tagger ? merge(var.tags, module.tagger[0].tags) : var.tags
}
