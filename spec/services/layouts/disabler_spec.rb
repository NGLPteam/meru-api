# frozen_string_literal: true

RSpec.describe Layouts::Disabler do
  describe "#disable!" do
    it "disables layout invalidation within the block" do
      disabler = described_class.new

      expect(Layouts::Disabled).not_to be_currently

      disabler.disable! do
        expect(Layouts::Disabled).to be_currently
      end

      expect(Layouts::Disabled).not_to be_currently
    end
  end
end
