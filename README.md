Terraform AWS Organisation
==========================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-organization.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-organization)

A Terraform module for managing an AWS Organisation.

The Organisation deployment has no requirements.
 
The Organisation deployment consists of:
* 

Usage
-----

To use the module, include something like the following in your terraform
configuration:

```hcl-terraform
module "organisation" {
  source = "infrablocks/organisation/aws"
  version = "0.1.1"
  
  region = "eu-west-2"
  vpc_id = "vpc-fb7dc365"
  
  component = "important-component"
  deployment_identifier = "production"
}
```

### Inputs

| Name                  | Description                                      | Default | Required |
|-----------------------|--------------------------------------------------|:-------:|:--------:|
| region                | The region into which to deploy the cache        | -       | yes      |
| vpc_id                | The ID of the VPC into which to deploy the cache | -       | yes      |
| component             | The component this cache will contain            | -       | yes      |
| deployment_identifier | An identifier for this instantiation             | -       | yes      |

### Outputs

| Name | Description |
|------|-------------|

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed 
on your development machine:

* Ruby (2.4.7)
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
rbenv install 2.3.1
rbenv rehash
rbenv local 2.3.1
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
aws-vault exec <profile> -- ./go deployment:harness:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:harness:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:destroy[<deployment_identifier>]
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
