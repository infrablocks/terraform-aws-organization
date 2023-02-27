module "organization" {
  source = "../../"

  feature_set = "ALL"

  organization = {
      name = "MyCompany",
      accounts = [
        {
          name = "MyCompany"
          email = "root@company.com"
        }
      ]
      units = [
        {
          name = "MyProduct",
          units = [
            {
              name = "Development",
              accounts = [
                {
                  name = "Development"
                  email = "development@company.com"
                }
              ]
            },
            {
              name = "Production",
              accounts = [
                {
                  name = "Production"
                  email = "production@company.com"
                }
              ]
            }
          ]
        }
      ]
    }
}
