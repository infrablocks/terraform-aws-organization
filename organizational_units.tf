locals {
  level_1_ou_arguments = [
    for ou in var.organizational_units : ou
  ]
  level_2_ou_arguments = flatten([
    for level_1_ou in var.organizational_units :
    [for level_2_ou in level_1_ou.children :
      {
        name : level_2_ou.name,
        parent : index(var.organizational_units, level_1_ou)
      }
    ]
  ])
  level_3_ou_arguments = flatten([
    for level_1_ou in var.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        {
          name : level_3_ou.name,
          parent : index(level_1_ou.children, level_2_ou)
        }
      ]
    ]
  ])
  level_4_ou_arguments = flatten([
    for level_1_ou in var.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        [for level_4_ou in level_3_ou.children :
          {
            name : level_4_ou.name,
            parent : index(level_2_ou.children, level_3_ou)
          }
        ]
      ]
    ]
  ])
  level_5_ou_arguments = flatten([
    for level_1_ou in var.organizational_units :
    [for level_2_ou in level_1_ou.children :
      [for level_3_ou in level_2_ou.children :
        [for level_4_ou in level_3_ou.children :
          [for level_5_ou in level_4_ou.children :
            {
              name : level_5_ou.name,
              parent : index(level_3_ou.children, level_4_ou)
            }
          ]
        ]
      ]
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  count     = length(local.level_1_ou_arguments)
  name      = local.level_1_ou_arguments[count.index].name
  parent_id = var.root_id
}

resource "aws_organizations_organizational_unit" "level_2_ous" {
  count     = length(local.level_2_ou_arguments)
  name      = local.level_2_ou_arguments[count.index].name
  parent_id = aws_organizations_organizational_unit.level_1_ous[local.level_2_ou_arguments[count.index].parent].id
}

resource "aws_organizations_organizational_unit" "level_3_ous" {
  count     = length(local.level_3_ou_arguments)
  name      = local.level_3_ou_arguments[count.index].name
  parent_id = aws_organizations_organizational_unit.level_2_ous[local.level_3_ou_arguments[count.index].parent].id
}

resource "aws_organizations_organizational_unit" "level_4_ous" {
  count     = length(local.level_4_ou_arguments)
  name      = local.level_4_ou_arguments[count.index].name
  parent_id = aws_organizations_organizational_unit.level_3_ous[local.level_4_ou_arguments[count.index].parent].id
}

resource "aws_organizations_organizational_unit" "level_5_ous" {
  count     = length(local.level_5_ou_arguments)
  name      = local.level_5_ou_arguments[count.index].name
  parent_id = aws_organizations_organizational_unit.level_4_ous[local.level_5_ou_arguments[count.index].parent].id
}

locals {
  level_1_ou_attributes = [
    for ou in local.level_1_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_1_ous[index(local.level_1_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_1_ous[index(local.level_1_ou_arguments, ou)].arn,
      parent_id = var.root_id,
      name      = ou.name,
    }
  ]
  level_2_ou_attributes = [
    for ou in local.level_2_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_2_ous[index(local.level_2_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_2_ous[index(local.level_2_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organizational_unit.level_1_ous[ou.parent].id,
      name      = ou.name
    }
  ]
  level_3_ou_attributes = [
    for ou in local.level_3_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_3_ous[index(local.level_3_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_3_ous[index(local.level_3_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organizational_unit.level_2_ous[ou.parent].id,
      name      = ou.name
    }
  ]
  level_4_ou_attributes = [
    for ou in local.level_4_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_4_ous[index(local.level_4_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_4_ous[index(local.level_4_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organizational_unit.level_3_ous[ou.parent].id,
      name      = ou.name
    }
  ]
  level_5_ou_attributes = [
    for ou in local.level_5_ou_arguments :
    {
      id        = aws_organizations_organizational_unit.level_5_ous[index(local.level_5_ou_arguments, ou)].id,
      arn       = aws_organizations_organizational_unit.level_5_ous[index(local.level_5_ou_arguments, ou)].arn,
      parent_id = aws_organizations_organizational_unit.level_4_ous[ou.parent].id,
      name      = ou.name
    }
  ]
  all_ou_attributes = concat(
    local.level_1_ou_attributes,
    local.level_2_ou_attributes,
    local.level_3_ou_attributes,
    local.level_4_ou_attributes,
    local.level_5_ou_attributes
  )
}