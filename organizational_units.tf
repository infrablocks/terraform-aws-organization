locals {
  level_1_ou_arguments = [
    for ou in local.organization : ou
  ]
  level_2_ou_arguments = flatten([
    for level_1_ou in local.organization :
    [for level_2_ou in level_1_ou.units :
      {
        name: level_2_ou.name,
        parent: level_1_ou.name
      }
    ]
  ])
  level_3_ou_arguments = flatten([
    for level_1_ou in local.organization :
    [for level_2_ou in level_1_ou.units :
     [for level_3_ou in level_2_ou.units :
       {
         name: level_3_ou.name,
         parent: level_2_ou.name
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

resource "aws_organizations_organizational_unit" "level_2_ous" {
  for_each = { for record in local.level_2_ou_arguments : record.name => record  }
  name = each.value.name
  parent_id = aws_organizations_organizational_unit.level_1_ous[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_3_ous" {
  for_each = { for record in local.level_3_ou_arguments : record.name => record  }
  name = each.value.name
  parent_id = aws_organizations_organizational_unit.level_2_ous[each.value.parent].id
}

locals {
  level_1_ou_attributes = [
    for ou in aws_organizations_organizational_unit.level_1_ous :
      {
        id = ou.id,
        arn = ou.arn,
        parent_id = ou.parent_id,
        name = ou.name,
      }
  ]
  level_2_ou_attributes = [
    for ou in aws_organizations_organizational_unit.level_2_ous :
      {
        id = ou.id,
        arn = ou.arn,
        parent_id = ou.parent_id,
        name = ou.name,
      }
  ]
  level_3_ou_attributes = [
    for ou in aws_organizations_organizational_unit.level_3_ous :
    {
      id = ou.id,
      arn = ou.arn,
      parent_id = ou.parent_id,
      name = ou.name,
    }
  ]
  all_ou_attributes = {
    for ou in concat(
      local.level_1_ou_attributes,
      local.level_2_ou_attributes,
      local.level_3_ou_attributes
    ) :
    ou.id => ou
  }
}
