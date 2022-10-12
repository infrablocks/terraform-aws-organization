variable "region" {}

variable "feature_set" {
  type = string
  default = null
}

variable "organizational_units" {
  type = list(object({
    name = string,
    children = list(object({
      name = string,
      children = list(object({
        name = string
      }))
    }))
  }))
  default = null
}

variable "accounts" {
  type = list(object({
    name = string,
    email = string,
    organizational_unit = string,
    allow_iam_users_access_to_billing = bool,
  }))
  default = null
}

