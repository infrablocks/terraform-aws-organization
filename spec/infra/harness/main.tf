data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "organization" {
  # This makes absolutely no sense. I think there's a bug in terraform.
  source = "./../../../../../../../"

  feature_set = var.feature_set

  organizational_units = var.organizational_units
}
