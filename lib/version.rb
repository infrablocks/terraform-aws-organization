module Semantic
  module Extensions
    def release!
      if pre.nil?
        raise RuntimeError.new(
            "Error: no pre segment, this version is not a pre-release version.")
      end

      new_version = clone
      new_version.build = new_version.pre = nil
      new_version
    end

    def rc!
      new_version = clone

      if new_version.pre.nil?
        new_version = new_version.increment!(:minor)
        new_version.pre = 'rc.1'
        return new_version
      end

      if new_version.pre =~ /^rc\.\d+$/
        new_version.pre = "rc.#{Integer(new_version.pre.delete('rc.')) + 1}"
        return new_version
      end

      raise RuntimeError.new(
          "Error: pre segment '#{new_version.pre}' does not look like 'rc.n'.")
    end
  end

  class Version
    prepend Extensions
  end
end
