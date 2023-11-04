resource "aws_organizations_organization" "organization" {
  feature_set = var.feature_set
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types = var.enabled_policy_types
}
