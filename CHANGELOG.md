## 2.0.0 (October 12th, 2022)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 1.3 and higher.
* The variables `organizational_units` and `accounts` have been replaced by a
  generic `organization` variable which describes the account hierarchy and the
  generated organizational units and accounts are inferred from this variable.
  See the `examples` directory for a basic example.
* This module now uses organizational unit and account indexing by name rather
  than array index. This means that if you try to upgrade from 1.x.x the module
  will suggest that it needs to destroy all existing resources and create new
  ones. To overcome this you will need to manually update your Terraform state
  file.
* This module now uses organizational unit and account output indexing by id
  rather than array index. This means that if you're leveraging the outputs in
  other modules you'll need to update the usage. 

## 1.1.0 (October 12th, 2022)

IMPROVEMENTS:

* Any AWS provider with version greater than or equal to 3.29 can now be used
  with this module.
* A new variable, `aws_service_access_principals`, can now be provided to
  configure the AWS service access principals for which integration is enabled
  in the organization.

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 1.0 and higher.

## 1.0.0 (May 28th, 2021)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 0.14 and higher.
