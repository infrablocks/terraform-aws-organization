require 'aws-sdk'
require 'awspec'

require_relative '../terraform_module'

shared_context :terraform do
  include Awspec::Helper::Finder

  let(:organizations_client) { Aws::Organizations::Client.new }

  let(:vars) {TerraformModule.configuration.for(:harness).vars}

  def output_for(role, name)
    TerraformModule.output_for(role, name)
  end

  def reprovision(overrides = nil)
    TerraformModule.provision_for(
        :harness,
        TerraformModule.configuration.for(:harness, overrides).vars)
  end
end