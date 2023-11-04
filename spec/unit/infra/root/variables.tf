variable "region" {}

variable "feature_set" {
  type    = string
  default = null
}

variable "aws_service_access_principals" {
  type    = list(string)
  default = null
}

variable "enabled_policy_types" {
  type    = list(string)
  default = null
}

variable "organization" {
  type = object({
    accounts = optional(list(object({
      name                              = string,
      key                               = string,
      email                             = string,
      allow_iam_users_access_to_billing = optional(bool, null),
    })), [])
    units = optional(list(object({
      name     = string,
      key      = string,
      accounts = optional(list(object({
        name                              = string,
        key                               = string,
        email                             = string,
        allow_iam_users_access_to_billing = optional(bool, null),
      })), [])
      units = optional(list(object({
        name     = string,
        key      = string,
        accounts = optional(list(object({
          name                              = string,
          key                               = string,
          email                             = string,
          allow_iam_users_access_to_billing = optional(bool, null),
        })), [])
        units = optional(list(object({
          name     = string,
          key      = string,
          accounts = optional(list(object({
            name                              = string,
            key                               = string,
            email                             = string,
            allow_iam_users_access_to_billing = optional(bool, null),
          })), [])
          units = optional(list(object({
            name     = string,
            key      = string,
            accounts = optional(list(object({
              name                              = string,
              key                               = string,
              email                             = string,
              allow_iam_users_access_to_billing = optional(bool, null),
            })), [])
            units = optional(list(object({
              name     = string,
              key      = string,
              accounts = optional(list(object({
                name                              = string,
                key                               = string,
                email                             = string,
                allow_iam_users_access_to_billing = optional(bool, null),
              })), [])
            })), [])
          })), [])
        })), [])
      })), [])
    })), [])
  })
  default = null
}
