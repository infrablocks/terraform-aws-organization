# frozen_string_literal: true

require 'spec_helper'

describe 'basic' do
  before(:context) do
    apply(role: :basic)
  end

  after(:context) do
    destroy(role: :basic)
  end

  let(:organizations_client) { Aws::Organizations::Client.new }

  let(:defined_organizational_units) do
    [
      {
        name: 'Fulfillment',
        children: [
          {
            name: 'Warehouse',
            children: [
              {
                name: 'London',
                children: []
              },
              {
                name: 'Edinburgh',
                children: []
              }
            ]
          }
        ]
      }
    ]
  end

  let(:organization) do
    organizations_client.describe_organization.organization
  end

  let(:root) do
    organizations_client.list_roots.roots[0]
  end

  describe 'organization' do
    it 'uses a feature set of "ALL"' do
      expect(organization.feature_set).to(eq('ALL'))
    end
  end

  describe 'organizational_units' do
    it 'has organizational units under root' do
      fulfillment_organizational_unit =
        organizations_client.list_organizational_units_for_parent(
          parent_id: root.id
        ).organizational_units[0]

      expect(fulfillment_organizational_unit.name)
        .to(eq(defined_organizational_units[0][:name]))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'has organizational units under first level' do
      fulfillment_organizational_unit =
        organizations_client.list_organizational_units_for_parent(
          parent_id: root.id
        ).organizational_units[0]
      child_organizational_units =
        organizations_client.list_organizational_units_for_parent(
          parent_id: fulfillment_organizational_unit.id
        ).organizational_units

      expect(child_organizational_units.size).to(eq(1))
      expect(child_organizational_units[0].name)
        .to(eq(defined_organizational_units[0][:children][0][:name]))
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'has organizational units under second level' do
      fulfillment_organizational_unit =
        organizations_client.list_organizational_units_for_parent(
          parent_id: root.id
        ).organizational_units[0]
      warehouse_organizational_unit =
        organizations_client.list_organizational_units_for_parent(
          parent_id: fulfillment_organizational_unit.id
        ).organizational_units[0]
      child_organizational_units =
        organizations_client.list_organizational_units_for_parent(
          parent_id: warehouse_organizational_unit.id
        ).organizational_units
      child_definitions =
        defined_organizational_units[0][:children][0][:children]

      expect(child_organizational_units.size).to(eq(2))
      expect(child_organizational_units.map(&:name).to_set)
        .to(eq(child_definitions.map { |d| d[:name] }.to_set))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'outputs details of the created organizational units' do
      organizational_units =
        output(role: :basic, name: 'organizational_units')
      organizational_unit_names =
        organizational_units.map do |organizational_unit|
          organizational_unit[:name]
        end

      expect(organizational_unit_names)
        .to(contain_exactly(
              'Fulfillment',
              'Warehouse',
              'London',
              'Edinburgh'
            ))
    end
  end
end
