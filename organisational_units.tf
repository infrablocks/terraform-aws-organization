locals {
  level_1_ou_nodes = [for node in var.nodes : node if node.type == "organizational_unit"]
}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  count = length(local.level_1_ou_nodes)
  name = local.level_1_ou_nodes[count.index].name
  parent_id = aws_organizations_organization.organization.roots[0].id
}
