require 'bundler/setup'
require 'ruby_terraform'

require 'support/shared_contexts/terraform'
require 'support/terraform_module'

RubyTerraform.configure do |c|
  c.binary = Paths.from_project_root_directory(
      'vendor', 'terraform', 'bin', 'terraform')
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context :terraform

  config.before(:suite) do
    TerraformModule.provision_for(:prerequisites)
    TerraformModule.provision_for(:harness)
  end
  config.after(:suite) do
    begin
      TerraformModule.destroy_for(:harness)
    ensure
      TerraformModule.destroy_for(:prerequisites)
    end
  end
end
