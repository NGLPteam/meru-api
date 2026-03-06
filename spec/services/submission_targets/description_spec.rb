# frozen_string_literal: true

RSpec.describe SubmissionTargets::Description do
  let(:internal) { "Internal content" }
  let(:instructions) { "Prefix content" }
  let(:sections) { [] }

  let(:instance) do
    described_class.new(
      internal:,
      instructions:,
      sections:
    )
  end

  subject { instance }

  context "when provided a section with a missing name" do
    let!(:section) { FactoryBot.build(:submission_target_section, name: nil) }

    let!(:sections) do
      [
        section
      ]
    end

    it "invalidates the entire description" do
      expect do
        is_expected.to be_invalid
      end.to keep_the_same(section, :identifier)
    end
  end

  context "when provided dupe section names" do
    let!(:dupe_section_1) { FactoryBot.build(:submission_target_section, name: "Dupe") }
    let!(:valid_section) { FactoryBot.build(:submission_target_section, name: "Valid Section") }
    let!(:dupe_section_2) { FactoryBot.build(:submission_target_section, name: "Dupe") }

    let!(:sections) do
      [
        dupe_section_1,
        valid_section,
        dupe_section_2
      ]
    end

    it "handles generating unique identifiers" do
      expect do
        is_expected.to be_valid
      end.to change(dupe_section_1, :identifier).to("dupe")
        .and change(dupe_section_1, :position).to(1)
        .and change(valid_section, :identifier).to("valid-section")
        .and change(valid_section, :position).to(2)
        .and change(dupe_section_2, :identifier).to("dupe--3")
        .and change(dupe_section_2, :position).to(3)

      expect(sections).to all(be_valid)
    end
  end
end
