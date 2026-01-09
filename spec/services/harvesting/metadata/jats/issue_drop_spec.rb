# frozen_string_literal: true

# This test specifically addresses coercion issues with {Harvesting::Metadata::Drops::DataExtractor}
# and {Harvesting::Metadata::Drops::MapsDataAttrs} when handling values that cannot be coerced properly.
RSpec.describe Harvesting::Metadata::JATS::IssueDrop do
  let(:id) { "issue-123" }
  let(:seq) { "42" }
  let(:content) { "Issue content" }

  let(:data) do
    instance_double(Niso::Jats::Issue, id:, content:, seq:)
  end

  let(:article) { instance_double(Niso::Jats::Article) }

  let(:metadata_context) do
    instance_double(Harvesting::Metadata::JATS::Context, article:)
  end

  let(:drop) do
    described_class.new(data, metadata_context:)
  end

  context "with a valid seq" do
    it "coerces the seq" do
      expect(drop.seq).to eq 42
    end
  end

  context "when the seq value is an empty string" do
    let(:seq) { "" }

    it "returns nil for seq" do
      expect(drop.seq).to be_nil
    end
  end

  context "when the seq value is invalid" do
    let(:seq) { "not a number" }

    it "returns nil for seq" do
      expect(drop.seq).to be_nil
    end
  end
end
