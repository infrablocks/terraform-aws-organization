locals {
  level_1_ou_arguments = [
    for ou in local.organizational_units : ou
  ]
  level_2_ou_arguments = flatten([
    for level_1_ou in local.organizational_units :
    [for level_2_ou in level_1_ou.children :
      {
        name: level_2_ou.name,
        parent: index(local.organizational_units, level_1_ou)
      }
    ]
  ])
  level_3_ou_arguments = flatten([
    for level_1_ou in local.organizational_units :
    [for level_2_ou in level_1_ou.children :
     [for level_3_ou in level_2_ou.children :
       {
         name: level_3_ou.name,
         parent: index(level_1_ou.children, level_2_ou)
       }
     ]
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  for_each = { for record in local.level_1_ou_arguments : record.name => record  }
  name = each.value.name
  parent_id = aws_organizations_organization.organization.roots[0].id
}

resource "aws_organizations_organizational_unit"  "level_2_ous" {
  for_each = { for record in local.level_2_ou_arguments : record.name => record  }
  name = each.value.name
  parent_id = aws_organizations_organizational_unit.level_1_ous[local.level_1_ou_arguments[each.value.parent].name].id
}

resource "aws_organizations_organizational_unit"  "level_3_ous" {
  for_each = { for record in local.level_3_ou_arguments : record.name => record  }
  name = each.value.name
  parent_id = aws_organizations_organizational_unit.level_2_ous[local.level_2_ou_arguments[each.value.parent].name].id
}

locals {
  level_1_ou_attributes = [
    for ou in local.level_1_ou_arguments :
      {
        id = aws_organizations_organizational_unit.level_1_ous[ou.name].id,
        arn = aws_organizations_organizational_unit.level_1_ous[ou.name].arn,
        parent_id = aws_organizations_organization.organization.roots[0].id,
        name = ou.name,
      }
  ]
  level_2_ou_attributes = [
    for ou in local.level_2_ou_arguments :
      {
        id = aws_organizations_organizational_unit.level_2_ous[ou.name].id,
        arn = aws_organizations_organizational_unit.level_2_ous[ou.name].arn,
        parent_id = aws_organizations_organizational_unit.level_1_ous[local.level_1_ou_arguments[ou.parent].name].id,
        name = ou.name
      }
  ]
  level_3_ou_attributes = [
    for ou in local.level_3_ou_arguments :
      {
        id = aws_organizations_organizational_unit.level_3_ous[ou.name].id,
        arn = aws_organizations_organizational_unit.level_3_ous[ou.name].arn,
        parent_id = aws_organizations_organizational_unit.level_2_ous[local.level_2_ou_arguments[ou.parent].name].id,
        name = ou.name
      }
  ]
  all_ou_attributes = concat(
    local.level_1_ou_attributes,
    local.level_2_ou_attributes,
    local.level_3_ou_attributes
  )
}
