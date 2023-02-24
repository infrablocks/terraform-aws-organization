variable "region" {}

variable "feature_set" {
  type = string
  default = null
}

variable "aws_service_access_principals" {
  type = list(string)
  default = null
}

variable "organization" {
  type = list(object({
    name = string,
    accounts = optional(list(object({
      name = string,
      email = string,
      allow_iam_users_access_to_billing = bool,
    })), [])
    units = optional(list(object({
      name = string,
      accounts = optional(list(object({
        name = string,
        email = string,
        allow_iam_users_access_to_billing = bool,
      })), [])
      units = optional(list(object({
        name = string
        accounts = optional(list(object({
          name = string,
          email = string,
          allow_iam_users_access_to_billing = bool,
        })), [])
      })), [])
    })), [])
  }))
  default = null
}
