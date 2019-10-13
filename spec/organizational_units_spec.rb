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
      reprovision({
          nodes: [
              {
                  type: "organizational_unit",
                  name: "Fulfillment"
              },
              {
                  type: "organizational_unit",
                  name: "Online"
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
end
