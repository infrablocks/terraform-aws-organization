data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "organization" {
  source = "../../../.."

  feature_set                   = var.feature_set
  aws_service_access_principals = var.aws_service_access_principals
  organizational_units          = var.organizational_units
  accounts                      = var.accounts
}
