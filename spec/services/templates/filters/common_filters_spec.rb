# frozen_string_literal: true

RSpec.describe Templates::Filters::CommonFilters, liquid_templates: true do
  let_it_be(:environment) do
    Liquid::Environment.build(error_mode: :strict) do |env|
      env.register_filter described_class
    end
  end

  let(:source) { "" }

  let(:template) { Liquid::Template.parse(source, environment:) }

  def expect_rendering(**extra)
    values = assigns.merge(extra).stringify_keys

    expect(template.render(values))
  end

  describe "cc_license_link" do
    let(:source) { "{{ value | cc_license_link }}" }

    context "with a known license" do
      let_assign!(:value) { "CC BY-SA" }

      it "renders the correct link" do
        expect_rendering.to include("https://creativecommons.org/licenses/by-sa/2.5/")
      end
    end

    context "with an unknown license" do
      let_assign!(:value) { "Unknown License" }

      it "renders an empty string" do
        expect_rendering.to eq("")
      end
    end
  end

  describe "date" do
    context "with a variable precision date" do
      let_assign!(:value) { VariablePrecisionDate.parse("2020-05") }

      let(:source) { "{{ value | date: '%B %d, %Y' }}" }

      it "renders the date according to the format" do
        expect_rendering.to eq("May 01, 2020")
      end
    end

    context "with a variable precision date drop" do
      let_assign!(:value) { Templates::Drops::VariablePrecisionDateDrop.new(VariablePrecisionDate.parse("2021-12-15")) }

      let(:source) { "{{ value | date: '%B %d, %Y' }}" }

      it "renders the date according to the format" do
        expect_rendering.to eq("December 15, 2021")
      end
    end

    context "with a standard date" do
      let_assign!(:value) { Date.new(2019, 7, 4) }

      let(:source) { "{{ value | date: '%B %d, %Y' }}" }

      it "renders the date according to the format" do
        expect_rendering.to eq("July 04, 2019")
      end
    end

    context "with an invalid date" do
      let_assign!(:value) { "not a date" }

      let(:source) { "{{ value | date: '%B %d, %Y' }}" }

      it "does nothing" do
        expect_rendering.to eq value
      end
    end
  end

  describe "doi_link" do
    let(:source) { "{{ value | doi_link }}" }

    context "with a valid DOI" do
      let_assign!(:value) { "10.1000/xyz123" }

      it "renders the DOI link" do
        expect_rendering.to include("https://doi.org/10.1000/xyz123")
      end
    end

    context "with an invalid DOI" do
      let_assign!(:value) { "invalid_doi" }

      it "returns the original value" do
        expect_rendering.to eq("invalid_doi")
      end
    end
  end

  describe "doi_url" do
    let(:source) { "{{ value | doi_url }}" }

    context "with a valid DOI" do
      let_assign!(:value) { "10.1000/xyz123" }

      it "renders the DOI URL" do
        expect_rendering.to eq("https://doi.org/10.1000/xyz123")
      end
    end

    context "with an invalid DOI" do
      let_assign!(:value) { "invalid_doi" }

      it "returns the original value" do
        expect_rendering.to eq("invalid_doi")
      end
    end
  end

  describe "pluralize" do
    let_assign!(:count) { 0 }

    let(:source) { "{{ count | pluralize: 'item' }}" }

    context "when count is zero" do
      let_assign!(:count) { 0 }

      it "returns the plural form" do
        expect_rendering.to eq("0 items")
      end
    end

    context "when count is one" do
      let_assign!(:count) { 1 }

      it "returns the singular form" do
        expect_rendering.to eq("1 item")
      end
    end

    context "when count is > 1" do
      let_assign!(:count) { 2 }

      it "returns the plural form" do
        expect_rendering.to eq("2 items")
      end
    end
  end
end
