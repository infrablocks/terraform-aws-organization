variable "region" {}

variable "feature_set" {}

variable "nodes" {
  type = list(object({
    type = string,
    name = string
  }))
}
