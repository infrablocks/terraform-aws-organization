data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}
