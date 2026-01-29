# frozen_string_literal: true

RSpec.describe JournalSources::Parsed::Unknown, type: :parsed_journal_source do
  context "with no attributes provided" do
    it_behaves_like "a valid parsed journal source", :unknown
  end
end
