# frozen_string_literal: true

RSpec.shared_context "liquid tag testing" do
  # @abstract
  # Override in including spec
  # @param [Liquid::Environment] env
  # @return [void]
  def augment_liquid_environment!(env); end

  let_it_be(:strict_environment) do
    Liquid::Environment.build(error_mode: :strict) do |env|
      augment_liquid_environment!(env)
    end
  end

  let_it_be(:lax_environment) do
    Liquid::Environment.build(error_mode: :lax) do |env|
      augment_liquid_environment!(env)
    end
  end

  let(:assigns) { {} }

  let(:environment) { strict_environment }

  let(:template_body) { "" }

  let(:template) do
    Liquid::Template.parse(template_body, environment:)
  end

  def rendering_with(render_assigns, strict_variables: true, strict_filters: true)
    template.render(
      render_assigns,
      strict_variables:,
      strict_filters:,
    ).strip
  end

  def expect_rendering_with(...)
    expect(rendering_with(...))
  end
end
