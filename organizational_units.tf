locals {
  level_1_ous = [
    for ou in var.organizational_units : ou
  ]
  level_2_ous = flatten([
    for level_1_ou in local.level_1_ous :
    [for level_2_ou in level_1_ou.children :
      {
        name: level_2_ou.name,
        parent: index(local.level_1_ous, level_1_ou)
      }
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  count = length(local.level_1_ous)
  name = local.level_1_ous[count.index].name
  parent_id = aws_organizations_organization.organization.roots[0].id
}

resource "aws_organizations_organizational_unit"  "level_2_ous" {
  count = length(local.level_2_ous)
  name = local.level_2_ous[count.index].name
  parent_id = aws_organizations_organizational_unit.level_1_ous[local.level_2_ous[count.index].parent].id
}
