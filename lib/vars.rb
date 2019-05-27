require 'yaml'
require 'ostruct'

require_relative 'template'

module Vars
  def self.load_from(file, context)
    YAML.load_file(file).to_a.reduce(OpenStruct.new) do |acc, var|
      var_name = var[0]
      var_value = var[1]

      method_name = "#{var_name}="
      normalised_value = var_value.is_a?(String) ?
          Template.new(var_value, context).render :
          var_value

      acc.send(method_name, normalised_value)
      acc
    end
  end
end