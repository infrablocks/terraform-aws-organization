locals {
  # default for cases when `null` value provided, meaning "use default"
  feature_set                   = var.feature_set == null ? "ALL" : var.feature_set
  aws_service_access_principals = var.aws_service_access_principals == null ? [] : var.aws_service_access_principals
  organization                  = var.organization == null ? [] : var.organization
}
