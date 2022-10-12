locals {
  # default for cases when `null` value provided, meaning "use default"
  feature_set          = var.feature_set == null ? "ALL" : var.feature_set
  organizational_units = var.organizational_units == null ? [] : var.organizational_units
  accounts             = var.accounts == null ? [] : var.accounts
}
