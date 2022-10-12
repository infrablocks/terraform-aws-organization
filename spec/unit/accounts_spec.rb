# frozen_string_literal: true

require 'spec_helper'

describe 'accounts' do
  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'outputs an empty list of accounts' do
      expect(@plan)
        .to(include_output_creation(name: 'accounts')
              .with_value([]))
    end

    it 'does not create any accounts' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_organizations_account'
                ))
    end
  end

  context 'when no accounts specified' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.accounts = []
      end
    end

    it 'outputs an empty list of accounts' do
      expect(@plan)
        .to(include_output_creation(name: 'accounts')
              .with_value([]))
    end

    it 'does not create any accounts' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_organizations_account'
                ))
    end
  end

  context 'when one account specified' do
    describe 'by default' do
      before(:context) do
        @account_name = 'Fulfillment'
        @account_email = 'fulfillment@example.com'
        @account_organizational_unit = 'Fulfillment'

        @plan = plan(role: :root) do |vars|
          vars.organizational_units = [
            {
              name: @account_organizational_unit,
              children: []
            }
          ]
          vars.accounts = [
            account(name: @account_name,
                    email: @account_email,
                    organizational_unit: @account_organizational_unit)
          ]
        end
      end

      it 'outputs details of the account' do
        expect(@plan)
          .to(include_output_creation(name: 'accounts')
                .with_value(containing_exactly(
                              hash_including(name: @account_name,
                                             email: @account_email)
                            )))
      end

      it 'creates the account' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, @account_name))
      end

      it 'uses the supplied email address' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, @account_name)
                .with_attribute_value(:email, @account_email))
      end
    end

    context 'when allow_iam_users_access_to_billing is true' do
      before(:context) do
        @account_name = 'Fulfillment'
        @account_organizational_unit = 'Fulfillment'

        @plan = plan(role: :root) do |vars|
          vars.organizational_units = [
            {
              name: @account_organizational_unit,
              children: []
            }
          ]
          vars.accounts = [
            account(name: @account_name,
                    allow_iam_users_access_to_billing: true,
                    organizational_unit: @account_organizational_unit)
          ]
        end
      end

      it 'allows IAM user access to billing' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, @account_name)
                .with_attribute_value(:iam_user_access_to_billing, 'ALLOW'))
      end
    end

    context 'when allow_iam_users_access_to_billing is false' do
      before(:context) do
        @account_name = 'Fulfillment'
        @account_organizational_unit = 'Fulfillment'

        @plan = plan(role: :root) do |vars|
          vars.organizational_units = [
            {
              name: @account_organizational_unit,
              children: []
            }
          ]
          vars.accounts = [
            account(name: @account_name,
                    allow_iam_users_access_to_billing: false,
                    organizational_unit: @account_organizational_unit)
          ]
        end
      end

      it 'does not allow IAM user access to billing' do
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, @account_name)
                .with_attribute_value(:iam_user_access_to_billing, 'DENY'))
      end
    end
  end

  context 'when many accounts specified' do
    before(:context) do
      @account1_name = 'Fulfillment'
      @account1_email = 'fulfillment@example.com'
      @account1_organizational_unit = 'Fulfillment'

      @account2_name = 'Billing'
      @account2_email = 'billing@example.com'
      @account2_organizational_unit = 'Billing'

      @account3_name = 'Online'
      @account3_email = 'online@example.com'
      @account3_organizational_unit = 'Online'

      @account1 = account(name: @account1_name,
                          email: @account1_email,
                          allow_iam_users_access_to_billing: true,
                          organizational_unit: @account1_organizational_unit)
      @account2 = account(name: @account2_name,
                          email: @account2_email,
                          allow_iam_users_access_to_billing: false,
                          organizational_unit: @account2_organizational_unit)
      @account3 = account(name: @account3_name,
                          email: @account3_email,
                          allow_iam_users_access_to_billing: true,
                          organizational_unit: @account3_organizational_unit)

      @accounts = [@account1, @account2, @account3]

      @accounts_with_billing_access = [@account1, @account3]
      @accounts_without_billing_access = [@account2]

      @plan = plan(role: :root) do |vars|
        vars.organizational_units = [
          {
            name: @account1_organizational_unit,
            children: []
          },
          {
            name: @account2_organizational_unit,
            children: []
          },
          {
            name: @account3_organizational_unit,
            children: []
          }
        ]
        vars.accounts = @accounts
      end
    end

    it 'outputs details of the accounts' do
      expect(@plan)
        .to(include_output_creation(name: 'accounts')
              .with_value(
                containing_exactly(
                  *@accounts.map do |a|
                    hash_including(name: a[:name], email: a[:email])
                  end
                )
              ))
    end

    it 'creates the accounts' do
      @accounts.each do |account|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, account[:name]))
      end
    end

    it 'uses the supplied email addresses' do
      @accounts.each do |account|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, account[:name])
                .with_attribute_value(:email, account[:email]))
      end
    end

    it 'allows IAM user billing access when requested' do
      @accounts_with_billing_access.each do |account|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, account[:name])
                .with_attribute_value(:iam_user_access_to_billing, 'ALLOW'))
      end
    end

    it 'denies IAM user billing access when requested' do
      @accounts_without_billing_access.each do |account|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_account'
          )
                .with_attribute_value(:name, account[:name])
                .with_attribute_value(:iam_user_access_to_billing, 'DENY'))
      end
    end
  end

  def account(overrides = {})
    id = SecureRandom.alphanumeric(4)
    {
      name: "test-#{id}",
      email: "test-#{id}@example.com",
      organizational_unit: 'SomeUnit',
      allow_iam_users_access_to_billing: false
    }.merge(overrides)
  end
end
