require 'ruby_terraform'
require 'ostruct'

require_relative '../../lib/configuration'

module TerraformModule
  class <<self
    def configuration
      @configuration ||= Configuration.new
    end

    def output_for(role, name)
      RubyTerraform.output(
          name: name,
          state: configuration.for(role).state_file,
          json: true)
    end

    def provision_for(role, overrides = nil)
      provision(configuration.for(role, overrides))
    end

    def provision(configuration)
      with_clean_directory(configuration) do
        puts
        puts "Provisioning with deployment identifier: " +
            configuration.deployment_identifier.to_s
        puts

        RubyTerraform.apply(
            state: configuration.state_file,
            directory: '.',
            vars: configuration.vars.to_h,
            auto_approve: true)

        puts
      end
    end

    def destroy_for(role, overrides = nil)
      destroy(configuration.for(role, overrides))
    end

    def destroy(configuration)
      unless ENV['DEPLOYMENT_IDENTIFIER']
        with_clean_directory(configuration) do
          puts
          puts "Destroying with deployment identifier: " +
              configuration.deployment_identifier.to_s
          puts

          RubyTerraform.destroy(
              state: configuration.state_file,
              directory: '.',
              vars: configuration.vars.to_h,
              force: true)

          puts
        end
      end
    end

    private

    def with_clean_directory(configuration)
      FileUtils.rm_rf(File.dirname(configuration.configuration_directory))
      FileUtils.mkdir_p(File.dirname(configuration.configuration_directory))
      FileUtils.cp_r(
          configuration.source_directory,
          configuration.configuration_directory)

      Dir.chdir(configuration.configuration_directory) do
        RubyTerraform.init
        yield configuration
      end
    end
  end
end