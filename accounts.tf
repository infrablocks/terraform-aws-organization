resource "aws_organizations_account" "account" {
  count = length(var.accounts)

  name  = var.accounts[count.index].name
  email = var.accounts[count.index].email

  iam_user_access_to_billing = var.accounts[count.index].allow_iam_users_access_to_billing ? "ALLOW" : "DENY"

  parent_id = [for ou in local.all_ou_attributes: ou.id if ou.name == var.accounts[count.index].organizational_unit][0]
}

locals {
  all_account_attributes = [
    for account in aws_organizations_account.account[*] :
      {
        id = account.id,
        arn = account.arn,
        name  = account.name
        email = account.email
        parent_id = account.parent_id,
        parent_ou = var.accounts[index(aws_organizations_account.account[*], account)].organizational_unit,
      }
    ]
}
