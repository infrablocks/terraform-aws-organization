# frozen_string_literal: true

require 'bundler/setup'

require 'aws-sdk'
require 'rspec'
require 'ruby_terraform'
require 'rspec/terraform'

Dir[File.join(__dir__, 'support', '**', '*.rb')]
  .each { |f| require f }

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.terraform_binary = 'vendor/terraform/bin/terraform'
  config.terraform_log_file_path = 'build/logs/unit.log'
  config.terraform_log_streams = [:file]
  config.terraform_configuration_provider =
    RSpec::Terraform::Configuration.chain_provider(
      providers: [
        RSpec::Terraform::Configuration.seed_provider,
        RSpec::Terraform::Configuration.in_memory_provider(
          no_color: true
        ),
        RSpec::Terraform::Configuration.confidante_provider(
          parameters: %i[
            configuration_directory
            state_file
            vars
          ],
          scope_selector: ->(o) { o.slice(:role) }
        )
      ]
    )

  config.before(:suite) do
    apply(
      role: :prerequisites
    )
  end
  config.after(:suite) do
    destroy(
      role: :prerequisites,
      only_if: -> { ENV['SEED'].nil? }
    )
  end
end
