# frozen_string_literal: true

require 'spec_helper'

describe 'organization' do
  let(:organization_arn) do
    output(role: :root, name: 'organization_arn')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'has a feature set of "ALL"' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_organizations_organization')
              .with_attribute_value(:feature_set, 'ALL'))
    end

    it 'has no AWS service access principals' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_organizations_organization')
              .with_attribute_value(:aws_service_access_principals, nil))
    end

    it 'outputs the organization ARN' do
      expect(@plan)
        .to(include_output_creation(name: 'organization_arn'))
    end
  end

  context 'when AWS service access principals are provided' do
    before(:context) do
      @aws_service_access_principals = %w[
        cloudtrail.amazonaws.com
        config.amazonaws.com
      ]

      @plan = plan(role: :root) do |vars|
        vars.aws_service_access_principals = @aws_service_access_principals
      end
    end

    it 'has the provided AWS service access principals' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_organizations_organization')
              .with_attribute_value(:aws_service_access_principals,
                                    @aws_service_access_principals))
    end
  end

  context 'when AWS service access principals is an empty list' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.aws_service_access_principals = []
      end
    end

    it 'has no AWS service access principals' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_organizations_organization')
              .with_attribute_value(:aws_service_access_principals, nil))
    end
  end

  context 'when a feature set of "CONSOLIDATED_BILLING" is specified' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.feature_set = 'CONSOLIDATED_BILLING'
      end
    end

    it 'has a feature set of "CONSOLIDATED_BILLING"' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_organizations_organization')
              .with_attribute_value(:feature_set, 'CONSOLIDATED_BILLING'))
    end
  end

  context 'when a feature set of ALL is specified' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.feature_set = 'ALL'
      end
    end

    it 'has a feature set of "ALL"' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_organizations_organization')
              .with_attribute_value(:feature_set, 'ALL'))
    end
  end
end
