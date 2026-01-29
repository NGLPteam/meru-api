# frozen_string_literal: true

RSpec.describe LiquidExt::Tags::IfPresent do
  include_context "liquid tag testing"

  def augment_liquid_environment!(env)
    env.register_tag "ifpresent", described_class
  end

  let_it_be(:root_drop) { LiquidTesting::Drops::RootDrop.new }

  let(:assigns) do
    {
      "root" => root_drop,
    }
  end

  let(:template_body) do
    <<~LIQUID
    {% ifpresent root.always_blank %}
    SHOULD NOT BE SEEN
    {% elsifpresent root.always_blank.anything %}
    NEVER REACHED
    {% elsifpresent root.falsey_primitive %}
    NOT EXISTING
    {% elsifpresent root.child.nonexistingmethod %}
    ALSO NOT EXISTING
    {% elsifpresent root.child.grandchild and false %}
    BOOLEAN LOGIC WORKS
    {% elsifpresent root.child.grandchild %}
    GRANDCHILD FOUND
    {% else %}
    ELSE BLOCK REACHED
    {% endifpresent %}
    LIQUID
  end

  shared_examples_for "rendering tests" do
    it "renders as expected with the right assigns" do
      expect_rendering_with(assigns).to eq "GRANDCHILD FOUND"

      expect(template.warnings).to be_blank
      expect(template.errors).to be_blank
    end

    it "handles empty assigns with no problem" do
      expect_rendering_with({}).to eq "ELSE BLOCK REACHED"

      expect(template.warnings).to be_blank
      expect(template.errors).to be_blank
    end
  end

  context "when in a strict environment" do
    let(:environment) { strict_environment }

    include_examples "rendering tests"
  end

  context "when in a lax environment" do
    let(:environment) { lax_environment }

    include_examples "rendering tests"
  end
end
