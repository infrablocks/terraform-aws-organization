resource "aws_organizations_organization" "organization" {
  feature_set = local.feature_set
}
