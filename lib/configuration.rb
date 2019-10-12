require 'securerandom'
require 'ostruct'
require 'confidante'

require_relative 'public_address'

class Configuration
  def initialize
    @random_deployment_identifier = SecureRandom.hex[0, 8]
    @delegate = Confidante.configuration
  end

  def deployment_identifier
    deployment_identifier_for(OpenStruct.new)
  end

  def deployment_identifier_for(args)
    args.deployment_identifier ||
        ENV['DEPLOYMENT_IDENTIFIER'] ||
        @random_deployment_identifier
  end

  def project_directory
    File.expand_path(File.join(File.dirname(__FILE__), ".."))
  end

  def work_directory
    @delegate.work_directory
  end

  def public_address
    PublicAddress.as_ip_address
  end

  def for(role, overrides = OpenStruct.new)
    @delegate
        .for_scope(role: role)
        .for_overrides({
            public_address: public_address,
            project_directory: project_directory,
            deployment_identifier: deployment_identifier_for(overrides)
        }.merge(overrides.to_h))
  end
end