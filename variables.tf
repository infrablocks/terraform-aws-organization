variable "feature_set" {
  type = string
  default = "ALL"
  description = "The feature set of the organization. One of 'ALL' or 'CONSOLIDATED_BILLING'."
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
