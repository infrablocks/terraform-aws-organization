# frozen_string_literal: true

require 'spec_helper'

describe 'organizational units' do
  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'outputs details of the the organizational units' do
      expect(@plan)
        .to(include_output_creation(name: 'organizational_units')
              .with_value({}))
    end

    it 'does not create any organizational units' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_organizations_organizational_unit'
                ))
    end
  end

  # TODO: work out how to check that the level one organizational units are
  #       under the organization root.
  describe 'when organizational units is one level deep' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.organization = [
          {
            name: 'Fulfillment',
            units: []
          },
          {
            name: 'Online',
            units: []
          }
        ]
      end
    end

    it 'creates organizational units for the first level' do
      %w[Fulfillment Online].each do |unit_name|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_organizational_unit'
          )
                .with_attribute_value(:name, unit_name))
      end
    end

    it 'outputs details on each organizational unit' do
      expect(@plan)
        .to(include_output_creation(name: 'organizational_units'))
    end
  end

  # TODO: work out how to check that the level one organizational units are
  #       under the organization root and level two organizational units are
  #       under the corresponding level one organizational units.
  context 'when organizational units is two levels deep' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.organization = [
          {
            name: 'Fulfillment',
            units: [
              {
                name: 'Warehouse',
                units: []
              },
              {
                name: 'Collections',
                units: []
              }
            ]
          }
        ]
      end
    end

    it 'creates organizational units for the first level' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'aws_organizations_organizational_unit'
        )
              .with_attribute_value(:name, 'Fulfillment'))
    end

    it 'creates organizational units for the second level' do
      %w[Warehouse Collections].each do |unit_name|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_organizational_unit'
          )
                .with_attribute_value(:name, unit_name))
      end
    end

    it 'outputs details on each organizational unit' do
      expect(@plan)
        .to(include_output_creation(name: 'organizational_units'))
    end
  end

  # TODO: work out how to check that the level one organizational units are
  #       under the organization root and level two organizational units are
  #       under the corresponding level one organizational units and level
  #       three organizational units are under the corresponding level two
  #       organizational units.
  context 'when organizational units is three levels deep' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.organization = [
          {
            name: 'Fulfillment',
            units: [
              {
                name: 'Warehouse',
                units: [
                  {
                    name: 'London',
                    units: []
                  },
                  {
                    name: 'Edinburgh',
                    units: []
                  }
                ]
              }
            ]
          }
        ]
      end
    end

    it 'creates organizational units for the first level' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'aws_organizations_organizational_unit'
        )
              .with_attribute_value(:name, 'Fulfillment'))
    end

    it 'creates organizational units for the second level' do
      expect(@plan)
        .to(include_resource_creation(
          type: 'aws_organizations_organizational_unit'
        )
              .with_attribute_value(:name, 'Warehouse'))
    end

    it 'creates organizational units for the third level' do
      %w[London Edinburgh].each do |unit_name|
        expect(@plan)
          .to(include_resource_creation(
            type: 'aws_organizations_organizational_unit'
          )
                .with_attribute_value(:name, unit_name))
      end
    end

    it 'outputs details on each organizational unit' do
      expect(@plan)
        .to(include_output_creation(name: 'organizational_units'))
    end
  end
end
