# frozen_string_literal: true

module Semantic
  module Extensions
    def release!
      unless prerelease?
        raise 'Error: no pre segment, ' \
              'this version is not a pre-release version.'
      end

      new_version = clone
      new_version.build = new_version.pre = nil
      new_version
    end

    def rc!
      return start_rc if release?
      return increment_rc if rc?

      raise "Error: pre segment '#{pre}' does not look like 'rc.n'."
    end

    private

    def start_rc
      new_version = clone
      new_version = new_version.increment!(:minor)
      new_version.pre = 'rc.1'
      new_version
    end

    def increment_rc
      new_version = clone
      new_version.pre = "rc.#{Integer(new_version.pre.delete('rc.')) + 1}"
      new_version
    end

    def release?
      pre.nil?
    end

    def prerelease?
      !release?
    end

    def rc?
      pre =~ /^rc\.\d+$/
    end
  end

  class Version
    prepend Extensions
  end
end
