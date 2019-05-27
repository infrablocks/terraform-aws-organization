require 'erb'

class Template
  def initialize(
      template,
      parameters = {})
    @template = template
    @parameters = parameters
  end

  def render
    context = Object.new
    @parameters.each do |key, value|
      context.instance_variable_set("@#{key}", value)
    end
    context_binding = context.instance_eval {binding}
    ERB.new(@template).result(context_binding)
  end
end