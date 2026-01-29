# frozen_string_literal: true

RSpec.describe JournalSources::Parsed::VolumeOnly, type: :parsed_journal_source do
  context "with valid attributes" do
    let(:volume) { "10" }
    let(:issue) { "2" }

    it_behaves_like "a valid parsed journal source", :volume_only
  end

  context "with a missing volume" do
    let(:volume) { nil }

    it_behaves_like "an invalid parsed journal source"
  end
end
