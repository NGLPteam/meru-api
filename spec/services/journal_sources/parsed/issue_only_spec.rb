# frozen_string_literal: true

RSpec.describe JournalSources::Parsed::IssueOnly, type: :parsed_journal_source do
  context "with valid attributes" do
    let(:issue) { "10" }
    let(:volume) { "2" }

    it_behaves_like "a valid parsed journal source", :issue_only
  end

  context "with a missing issue" do
    let(:issue) { nil }

    it_behaves_like "an invalid parsed journal source"
  end
end
