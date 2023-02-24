module "organization" {
  source = "../../"

  feature_set = "ALL"

  organization = [
    {
      name: "Fulfillment",
      units: [
        {
          name: "Warehouse",
          units: [
            {
              name: "London",
            },
            {
              name: "Edinburgh",
            }
          ]
        }
      ]
    }
  ]
}
