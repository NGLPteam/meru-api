# frozen_string_literal: true

RSpec.describe LiquidExt::Tags::IfInteger do
  include_context "liquid tag testing"

  def augment_liquid_environment!(env)
    env.register_tag "ifinteger", described_class
  end

  let(:firstish) { 123 }
  let(:secondish) { nil }

  let(:assigns) do
    {
      "firstish" => firstish,
      "secondish" => secondish,
    }
  end

  let(:template_body) do
    <<~LIQUID
    {% ifinteger firstish %}
    firstish is integer
    {% elsifinteger secondish %}
    secondish is integer
    {% else %}
    nothing is integer
    {% endifinteger %}
    LIQUID
  end

  shared_examples_for "a firstish match" do
    it "renders the first block" do
      expect_rendering_with(assigns).to eq "firstish is integer"

      expect(template.warnings).to be_blank
      expect(template.errors).to be_blank
    end
  end

  shared_examples_for "a secondish match" do
    it "renders the second block" do
      expect_rendering_with(assigns).to eq "secondish is integer"

      expect(template.warnings).to be_blank
      expect(template.errors).to be_blank
    end
  end

  shared_examples_for "no matches" do
    it "renders the else block" do
      expect_rendering_with(assigns).to eq "nothing is integer"

      expect(template.warnings).to be_blank
      expect(template.errors).to be_blank
    end
  end

  shared_examples_for "rendering tests" do
    context "when firstish is an actual integer" do
      let(:firstish) { 42 }
      let(:secondish) { "not an integer" }

      it_behaves_like "a firstish match"
    end

    context "when firstish is a string representation of an integer" do
      let(:firstish) { "-7" }

      it_behaves_like "a firstish match"
    end

    context "when secondish is an integer but firstish is not" do
      let(:firstish) { "not an integer" }
      let(:secondish) { 0 }

      it_behaves_like "a secondish match"
    end

    context "when neither firstish nor secondish are integers" do
      let(:firstish) { "foo" }
      let(:secondish) { "bar" }

      it_behaves_like "no matches"
    end

    context "when assigns are empty" do
      let(:assigns) { {} }

      it_behaves_like "no matches"
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
