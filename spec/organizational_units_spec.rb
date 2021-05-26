require 'spec_helper'

describe 'organizational units' do
  let(:organization_arn) do
    output_for(:harness, 'organization_arn')
  end

  let(:organization) do
    organizations_client.describe_organization.organization
  end

  let(:root) do
    organizations_client.list_roots.roots[0]
  end

  context "builds organizational units one level deep" do
    before(:all) do
      provision({
          organizational_units: [
              {
                  name: "Fulfillment",
                  children: []
              },
              {
                  name: "Online",
                  children: []
              }
          ]
      })
    end

    it 'has organizational units under root' do
      organizational_units =
          organizations_client.list_organizational_units_for_parent(
              parent_id: root.id
          ).organizational_units

      expect(organizational_units.size).to(eq(2))
      expect(organizational_units.map(&:name))
          .to(include('Fulfillment', 'Online'))
    end
  end

  context "build organizational units two levels deep" do
    before(:all) do
      provision({
          organizational_units: [
              {
                  name: "Fulfillment",
                  children: [
                      {
                          name: "Warehouse",
                          children: []
                      },
                      {
                          name: "Collections",
                          children: []
                      }
                  ]
              }
          ]
      })
    end

    it 'has organizational units under first level' do
      fulfillment_organizational_unit =
          organizations_client.list_organizational_units_for_parent(
              parent_id: root.id
          ).organizational_units[0]
      child_organizational_units =
          organizations_client.list_organizational_units_for_parent(
              parent_id: fulfillment_organizational_unit.id
          ).organizational_units

      expect(child_organizational_units.size).to(eq(2))
    end

    it 'outputs details of the created organizational units' do
      organizational_units_output =
          output_for(:harness, 'organizational_units')
      organizational_units = JSON.parse(organizational_units_output)
      organizational_unit_names =
          organizational_units.map do |organizational_unit|
            organizational_unit[:name]
          end

      expect(organizational_unit_names)
          .to(contain_exactly("Fulfillment", "Warehouse", "Collections"))
    end
  end

  context "build organizational units three levels deep" do
    before(:all) do
      provision({
          organizational_units: [
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
      })
    end

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
    end

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

      expect(child_organizational_units.size).to(eq(2))
    end

    it 'outputs details of the created organizational units' do
      organizational_units =
          output_for(:harness, 'organizational_units')
      organizational_unit_names =
          organizational_units.map do |organizational_unit|
            organizational_unit[:name]
          end

      expect(organizational_unit_names)
          .to(contain_exactly(
              "Fulfillment",
              "Warehouse",
              "London",
              "Edinburgh"))
    end
  end

end
