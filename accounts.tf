resource "aws_organizations_account" "account" {
  for_each = { for record in local.accounts : record.name => record  }

  name  = each.value.name
  email = each.value.email

  iam_user_access_to_billing = each.value.allow_iam_users_access_to_billing ? "ALLOW" : "DENY"

  parent_id = (each.value.organizational_unit == "root") ? aws_organizations_organization.organization.roots[0].id : [for ou in local.all_ou_attributes: ou.id if ou.name == each.value.organizational_unit][0]
}

locals {
  all_account_attributes = [
    for account in values(aws_organizations_account.account)[*] :
      {
        id = account.id,
        arn = account.arn,
        name  = account.name
        email = account.email
        parent_id = account.parent_id,
        parent_ou = local.accounts[index(values(aws_organizations_account.account)[*], account)].organizational_unit,
      }
    ]
}
