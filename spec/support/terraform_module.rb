require 'ruby_terraform'

require_relative '../../lib/configuration'

module TerraformModule
  class <<self
    def configuration
      @configuration ||= Configuration.new
    end

    def output_for(role, name)
      RubyTerraform.output(
          name: name,
          state: configuration.for(role).state_file)
    end

    def provision_for(role, vars = nil)
      provision(OpenStruct.new(
          configuration.for(role)
              .to_h.merge(vars: vars || configuration.for(role).vars)))
    end

    def provision(configuration)
      puts
      puts "Provisioning with deployment identifier: #{configuration.deployment_identifier}"
      puts

      FileUtils.rm_rf(File.dirname(configuration.configuration_directory))
      FileUtils.mkdir_p(File.dirname(configuration.configuration_directory))
      FileUtils.cp_r(
          configuration.source_directory,
          configuration.configuration_directory)

      Dir.chdir(configuration.configuration_directory) do
        RubyTerraform.init
        RubyTerraform.apply(
            state: configuration.state_file,
            directory: '.',
            vars: configuration.vars.to_h,
            auto_approve: true)
      end

      puts
    end

    def destroy_for(role, vars = nil)
      destroy(OpenStruct.new(
          configuration.for(role)
              .to_h.merge(vars: vars || configuration.for(role).vars)))
    end

    def destroy(configuration)
      unless ENV['DEPLOYMENT_IDENTIFIER']
        puts
        puts "Destroying with deployment identifier: #{configuration.deployment_identifier}"
        puts

        FileUtils.rm_rf(File.dirname(configuration.configuration_directory))
        FileUtils.mkdir_p(File.dirname(configuration.configuration_directory))
        FileUtils.cp_r(
            configuration.source_directory,
            configuration.configuration_directory)

        Dir.chdir(configuration.configuration_directory) do
          RubyTerraform.init
          RubyTerraform.destroy(
              state: configuration.state_file,
              directory: '.',
              vars: configuration.vars.to_h,
              force: true)
        end

        puts
      end
    end
  end
end