resource "aws_organizations_organization" "organization" {
  aws_service_access_principals = var.aws_service_access_principals
  feature_set                   = var.feature_set
}
