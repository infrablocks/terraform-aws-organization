data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "organisation" {
  source = "../../../../"

  feature_set = var.feature_set
}
