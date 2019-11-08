locals {
  level_1_ou_outputs = [
    for ou in local.level_1_ous :
      {
        id = aws_organizations_organizational_unit.level_1_ous[index(local.level_1_ous, ou)].id,
        arn = aws_organizations_organizational_unit.level_1_ous[index(local.level_1_ous, ou)].arn,
        parent_id = aws_organizations_organization.organization.roots[0].id,
        name = ou.name,
      }
  ]
  level_2_ou_outputs = [
    for ou in local.level_2_ous :
      {
        id = aws_organizations_organizational_unit.level_2_ous[index(local.level_2_ous, ou)].id,
        arn = aws_organizations_organizational_unit.level_2_ous[index(local.level_2_ous, ou)].arn,
        parent_id = aws_organizations_organizational_unit.level_1_ous[ou.parent].id,
        name = ou.name
      }
  ]
  level_3_ou_outputs = [
    for ou in local.level_3_ous :
      {
        id = aws_organizations_organizational_unit.level_3_ous[index(local.level_3_ous, ou)].id,
        arn = aws_organizations_organizational_unit.level_3_ous[index(local.level_3_ous, ou)].arn,
        parent_id = aws_organizations_organizational_unit.level_2_ous[ou.parent].id,
        name = ou.name
      }
  ]
}

output "organization_arn" {
  value = aws_organizations_organization.organization.arn
}

output "organizational_units" {
  value = concat(
    local.level_1_ou_outputs,
    local.level_2_ou_outputs,
    local.level_3_ou_outputs
  )
}
