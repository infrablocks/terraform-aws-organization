module "organization" {
  source = "../../"

  feature_set = "ALL"

  organizational_units = [
    {
      name: "Fulfillment",
      children: [
        {
          name: "Warehouse",
          children: [
            {
              name: "London",
              children: []
            },
            {
              name: "Edinburgh",
              children: []
            }
          ]
        }
      ]
    }
  ]
}
