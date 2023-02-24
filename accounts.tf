locals {
  level_1_account_arguments = flatten([
    for level_1_ou in local.organization :
    [for level_1_account in level_1_ou.accounts :
      {
        parent: [for ou in local.level_1_ou_attributes: ou if level_1_ou.name == ou.name][0],
        name: level_1_account.name,
        email: level_1_account.email
        allow_iam_users_access_to_billing: level_1_account.allow_iam_users_access_to_billing
      }
    ]
  ])
  level_2_account_arguments = flatten([
    for level_1_ou in local.organization :
    [for level_2_ou in level_1_ou.units :
      [for level_2_account in level_2_ou.accounts :
        {
          parent: [for ou in local.level_2_ou_attributes: ou if level_2_ou.name == ou.name][0],
          name: level_2_account.name,
          email: level_2_account.email
          allow_iam_users_access_to_billing: level_2_account.allow_iam_users_access_to_billing
        }
      ]
    ]
  ])
  level_3_account_arguments = flatten([
    for level_1_ou in local.organization :
    [for level_2_ou in level_1_ou.units :
      [for level_3_ou in level_2_ou.units :
        [for level_3_account in level_3_ou.accounts :
          {
            parent: [for ou in local.level_3_ou_attributes: ou if level_3_ou.name == ou.name][0],
            name: level_3_account.name,
            email: level_3_account.email
            allow_iam_users_access_to_billing: level_3_account.allow_iam_users_access_to_billing
          }
        ]
      ]
    ]
  ])
  all_accounts = concat(
    local.level_1_account_arguments,
    local.level_2_account_arguments,
    local.level_3_account_arguments
  )
}

resource "aws_organizations_account" "account" {
  for_each = { for record in local.all_accounts : record.name => record  }

  name  = each.value.name
  email = each.value.email

  iam_user_access_to_billing = each.value.allow_iam_users_access_to_billing ? "ALLOW" : "DENY"

  parent_id = each.value.parent.id
}

locals {
  all_account_attributes = {
    for account in values(aws_organizations_account.account)[*] :
      account.id => {
        id = account.id,
        arn = account.arn,
        name  = account.name
        email = account.email
        parent_id = account.parent_id,
      }
  }
}
