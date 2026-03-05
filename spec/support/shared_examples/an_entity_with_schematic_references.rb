# frozen_string_literal: true

RSpec.shared_examples_for "an entity with schematic references" do |var_name|
  let!(:entity) { public_send(var_name) }

  describe "#schematic_collected_references" do
    context "with only an invalid reference" do
      let!(:invalid_reference) { FactoryBot.create :schematic_collected_reference, path: "does_not.exist", referrer: entity }

      it "does not include an invalid reference" do
        expect(invalid_reference.referrer).to eq entity

        expect(entity.schematic_collected_references).to exclude invalid_reference
      end

      it "has an empty reference map" do
        expect(entity.schematic_collected_references.to_reference_map).to eq({})
      end
    end
  end

  describe "#schematic_scalar_references" do
    context "with only an invalid reference" do
      let!(:invalid_reference) { FactoryBot.create :schematic_scalar_reference, path: "does_not.exist", referrer: entity }

      it "does not include an invalid reference" do
        expect(invalid_reference.referrer).to eq entity

        expect(entity.schematic_scalar_references).to exclude invalid_reference
      end

      it "has an empty reference map" do
        expect(entity.schematic_scalar_references.to_reference_map).to eq({})
      end
    end
  end

  describe "#schematic_texts" do
    context "with only an invalid reference" do
      let!(:invalid_text) { FactoryBot.create :schematic_text, path: "does_not.exist", entity: }

      it "does not include an invalid text" do
        expect(invalid_text.entity).to eq entity

        expect(entity.schematic_texts).to exclude invalid_text
      end

      it "has an empty reference map" do
        expect(entity.schematic_texts.to_reference_map).to eq({})
      end
    end
  end
end
