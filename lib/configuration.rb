require 'securerandom'
require 'ostruct'
require 'confidante'

require_relative 'paths'
require_relative 'public_address'

class Configuration
  def initialize
    @random_deployment_identifier = SecureRandom.hex[0, 8].to_s
    @delegate = Confidante.configuration
  end

  def deployment_identifier
    deployment_identifier_for({})
  end

  def deployment_identifier_for(overrides)
    OpenStruct.new(overrides).deployment_identifier ||
        ENV['DEPLOYMENT_IDENTIFIER'] ||
        @random_deployment_identifier
  end

  def project_directory
    Paths.project_root_directory
  end

  def work_directory
    @delegate.work_directory
  end

  def public_address
    PublicAddress.as_ip_address
  end

  def for(role, overrides = nil)
    @delegate
        .for_scope(
            role: role,
            project_directory: project_directory
        )
        .for_overrides({
            public_address: public_address,
            project_directory: project_directory,
            deployment_identifier: deployment_identifier_for(overrides)
        }.merge(overrides.to_h))
  end
end