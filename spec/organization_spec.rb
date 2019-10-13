require 'spec_helper'

describe 'organization' do
  let(:organization_arn) do
    output_for(:harness, 'organization_arn')
  end

  let(:organization) do
    organizations_client.describe_organization.organization
  end

  context "when consolidated billing is specified" do
    before(:all) do
      reprovision({feature_set: "CONSOLIDATED_BILLING"})
    end

    it 'has a feature set of "CONSOLIDATED_BILLING"' do
      expect(organization.feature_set).to(eq("CONSOLIDATED_BILLING"))
    end
  end

  context "when all features are specified" do
    before(:all) do
      reprovision({feature_set: "ALL"})
    end

    it 'has a feature set of "ALL"' do
      expect(organization.feature_set).to(eq("ALL"))
    end
  end
end
