resource "aws_organizations_organization" "organization" {
  feature_set = local.feature_set
  aws_service_access_principals = local.aws_service_access_principals
}
