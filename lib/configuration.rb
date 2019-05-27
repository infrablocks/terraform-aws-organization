require 'securerandom'
require 'open-uri'
require 'ostruct'

require_relative 'paths'
require_relative 'vars'
require_relative 'public_address'

class Configuration
  def initialize
    @random_deployment_identifier = SecureRandom.hex[0, 8]
  end

  def deployment_identifier
    deployment_identifier_for(OpenStruct.new)
  end

  def deployment_identifier_for(args)
    args.deployment_identifier ||
        ENV['DEPLOYMENT_IDENTIFIER'] ||
        @random_deployment_identifier
  end

  def work_directory
    'build'
  end

  def for(role, args = OpenStruct.new)
    self.send("#{role}_parameters_for", args)
  end

  def prerequisites_parameters_for(args)
    module_parameters_for(
        deployment_identifier: deployment_identifier_for(args),
        source_directory: Paths.join('spec', 'infra', 'prerequisites'),
        work_directory: work_directory,
        state_file: Paths.from_project_root_directory(
            'state', 'prerequisites.tfstate'),
        vars_template_file: (ENV['PREREQUISITES_VARS_TEMPLATE_FILE'] ||
            Paths.from_project_root_directory(
                'config', 'vars', 'prerequisites.yml.erb')))
  end

  def harness_parameters_for(args)
    module_parameters_for(
        deployment_identifier: deployment_identifier_for(args),
        source_directory: Paths.join('spec', 'infra', 'harness'),
        work_directory: work_directory,
        state_file: Paths.from_project_root_directory(
            'state', 'harness.tfstate'),
        vars_template_file: (ENV['HARNESS_VARS_TEMPLATE_FILE'] ||
            Paths.from_project_root_directory(
                'config', 'vars', 'harness.yml.erb')))
  end

  def module_parameters_for(parameters)
    configuration_directory = File.join(
        parameters[:work_directory],
        parameters[:source_directory])
    vars = Vars.load_from(parameters[:vars_template_file], {
        project_directory: Paths.project_root_directory,
        public_ip: PublicAddress.as_ip_address,
        deployment_identifier: deployment_identifier
    })

    derived_parameters = {
        configuration_directory: configuration_directory,
        vars: vars
    }.merge(parameters)

    OpenStruct.new(derived_parameters)
  end
end