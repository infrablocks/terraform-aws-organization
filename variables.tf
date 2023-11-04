variable "feature_set" {
  description = "The feature set of the organization. One of 'ALL' or 'CONSOLIDATED_BILLING'."
  type        = string
  default     = "ALL"
  nullable    = false
}

variable "aws_service_access_principals" {
  description = "A list of AWS service principal names for which you want to enable integration with your organization."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "enabled_policy_types" {
  description = "The list of Organizations policy types to enable in the Organization Root. The organization must have `feature_set` set to `\"ALL\"`."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "organization" {
  description = "The organization with the tree of organizational units and accounts to construct. Defaults to an object with an empty list of units and accounts"
  type = object({
    accounts = optional(list(object({
      name                              = string,
      key                               = string,
      email                             = string,
      allow_iam_users_access_to_billing = optional(bool, true),
    })), [])
    units = optional(list(object({
      name     = string,
      key      = string,
      accounts = optional(list(object({
        name                              = string,
        key                               = string,
        email                             = string,
        allow_iam_users_access_to_billing = optional(bool, true),
      })), [])
      units = optional(list(object({
        name     = string,
        key      = string,
        accounts = optional(list(object({
          name                              = string,
          key                               = string,
          email                             = string,
          allow_iam_users_access_to_billing = optional(bool, true),
        })), [])
        units = optional(list(object({
          name     = string,
          key      = string,
          accounts = optional(list(object({
            name                              = string,
            key                               = string,
            email                             = string,
            allow_iam_users_access_to_billing = optional(bool, true),
          })), [])
          units = optional(list(object({
            name     = string,
            key      = string,
            accounts = optional(list(object({
              name                              = string,
              key                               = string,
              email                             = string,
              allow_iam_users_access_to_billing = optional(bool, true),
            })), [])
            units = optional(list(object({
              name     = string,
              key      = string,
              accounts = optional(list(object({
                name                              = string,
                key                               = string,
                email                             = string,
                allow_iam_users_access_to_billing = optional(bool, true),
              })), [])
            })), [])
          })), [])
        })), [])
      })), [])
    })), [])
  })
  default = {}
  nullable = false
}
