variable "feature_set" {
  type = string
  default = "ALL"
  description = "The feature set of the organization. One of 'ALL' or 'CONSOLIDATED_BILLING'."
}

variable "aws_service_access_principals" {
  type = list
  default = []
  description = "List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as sso.amazonaws.com."
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
  default = []
  description = "The tree of organizational units to construct. Defaults to an empty tree."
}

variable "accounts" {
  type = list(object({
    name = string,
    email = string,
    organizational_unit = string,
    allow_iam_users_access_to_billing = bool,
  }))
  default = []
  description = "The set of accounts to create. Defaults to an empty list."
}
