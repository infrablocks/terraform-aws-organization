Terraform AWS Organisation
==========================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-organization.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-organization)

A Terraform module for managing an AWS Organisation.

The Organisation deployment has no requirements.

The Organisation deployment consists of:

* an AWS organisation
* with a hierarchy of organisational units
* with a set of accounts placed in that hierarchy


Usage
-----

To use the module, include something like the following in your Terraform
configuration:

```hcl-terraform
module "organisation" {
  source  = "infrablocks/organisation/aws"
  version = "2.0.0"

  feature_set                   = "ALL"
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com"
  ]

  organization = {
    accounts = [
      {
        name = "Default"
        key = "mycompany-default"
        email = "root@company.com"
      }
    ]
    units = [
      {
        name = "MyProduct",
        key = "mycompany-myproduct"
        units = [
          {
            name = "Development",
            key = "mycompany-myproduct-development"
            accounts = [
              {
                name = "Blue"
                key = "mycompany-myproduct-development-blue"
                email = "development@company.com"
              }
            ]
          },
          {
            name = "Production",
            key = "mycompany-myproduct-production"
            accounts = [
              {
                name = "Blue"
                key = "mycompany-myproduct-production-blue"
                email = "production@company.com"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

Note: `organization` can be nested up to 5 levels deep. Levels 1 through 4 may include
a `units` property, although it can be an empty array. Level 5 must not include
a `units` property.

See the
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/organization/aws/latest)
for more details.

### Inputs

| Name                          | Description                                                                                            | Default | Required |
|-------------------------------|--------------------------------------------------------------------------------------------------------|:-------:|:--------:|
| feature_set                   | The feature set to enable for the organization (one of "ALL" or "CONSOLIDATED_BILLING")                |   ALL   |    no    |
| aws_service_access_principals | A list of AWS service principal names for which you want to enable integration with your organization. |   []    |    no    |
| organization                  | The tree of organizational units and accounts to construct. Defaults to an empty tree.                 |   []    |    no    |

### Outputs

| Name                 | Description                                       |
|----------------------|---------------------------------------------------|
| organization_arn     | The ARN of the resulting organization             |
| organizational_units | Details of the resulting organizational units     |
| accounts             | Details of the resulting accounts                 |

### Compatibility

This module is compatible with Terraform versions greater than or equal to
Terraform 1.3.

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed
on your development machine:

* Ruby (3.1.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv
* aws-vault

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 3.1.1
rbenv rehash
rbenv local 3.1.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# aws-vault
brew cask install

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

Running the build requires an AWS account and AWS credentials. You are free to
configure credentials however you like as long as an access key ID and secret
access key are available. These instructions utilise
[aws-vault](https://github.com/99designs/aws-vault) which makes credential
management easy and secure.

To provision module infrastructure, run tests and then destroy that
infrastructure, execute:

```bash
aws-vault exec <profile> -- ./go
```

To provision the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:destroy[<deployment_identifier>]
```

Configuration parameters can be overridden via environment variables:

```bash
DEPLOYMENT_IDENTIFIER=testing aws-vault exec <profile> -- ./go
```

When a deployment identifier is provided via an environment variable,
infrastructure will not be destroyed at the end of test execution. This can
be useful during development to avoid lengthy provision and destroy cycles.

By default, providers will be downloaded for each terraform execution. To
cache providers between calls:

```bash
TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache" aws-vault exec <profile> -- ./go
```

### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -m PEM -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Generating a self-signed certificate

To generate a self signed certificate:

```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```
openssl rsa -in key.pem -out ssl.key
```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/infrablocks/terraform-aws-organisation.
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

The library is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
