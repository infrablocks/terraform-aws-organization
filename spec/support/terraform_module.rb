# frozen_string_literal: true

require 'ruby_terraform'
require 'ostruct'
require 'json'

require_relative '../../lib/configuration'

module TerraformModule
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def output_for(role, name)
      params = {
        name: name,
        state: configuration.for(role).state_file,
        json: true
      }
      value = RubyTerraform.output(params)
      JSON.parse(value, symbolize_names: true)
    end

    def provision_for(role, overrides = nil)
      provision(configuration.for(role, overrides))
    end

    def provision(configuration)
      with_clean_directory(configuration) do
        puts
        puts "Provisioning with deployment identifier: #{configuration.deployment_identifier}"
        puts

        RubyTerraform.apply(
          chdir: configuration.configuration_directory,
          state: configuration.state_file,
          vars: configuration.vars.to_h,
          input: false,
          auto_approve: true
        )

        puts
      end
    end

    def destroy_for(role, overrides = nil, opts = {})
      destroy(configuration.for(role, overrides), opts)
    end

    def destroy(configuration, opts = {})
      if opts[:force] || !ENV['DEPLOYMENT_IDENTIFIER']
        with_clean_directory(configuration) do
          puts
          puts "Destroying with deployment identifier: #{configuration.deployment_identifier}"
          puts

          RubyTerraform.destroy(
            chdir: configuration.configuration_directory,
            state: configuration.state_file,
            vars: configuration.vars.to_h,
            input: false,
            auto_approve: true
          )

          puts
        end
      end
    end

    private

    def with_clean_directory(configuration)
      FileUtils.rm_rf(configuration.configuration_directory)
      FileUtils.mkdir_p(configuration.configuration_directory)

      RubyTerraform.init(
        chdir: configuration.configuration_directory,
        from_module: File.join(FileUtils.pwd, configuration.source_directory),
        input: false
      )
      yield configuration
    end
  end
end
