variable "feature_set" {
  type = string
  default = "ALL"
  description = "The feature set of the organization. One of 'ALL' or 'CONSOLIDATED_BILLING'."
}

variable "nodes" {
  type = list(object({
    type = string,
    name = string
  }))
  default = []
  description = "The tree of organisational units to construct. Defaults to an empty tree."
}
