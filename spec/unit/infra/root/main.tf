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
  organization                  = var.organization
}
