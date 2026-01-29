# frozen_string_literal: true

RSpec.describe JournalSources::Parse, type: :operation do
  let(:input) { nil }

  subject(:parsed) { operation.(input) }

  context "with a well-structured citation" do
    context "with multiple pages" do
      let(:input) do
        "Some Journal; Vol. 18 No. 5 (2022); 106-112"
      end

      it { is_expected.to be_full.and be_known }
      it { is_expected.to have_attributes(volume: "18", issue: ?5, year: 2022, fpage: 106, lpage: 112) }
    end

    context "with a single page" do
      let(:input) do
        "Some Journal; Vol. 5 No. 12 (2009); 3"
      end

      it { is_expected.to be_full.and be_known }
      it { is_expected.to have_attributes(volume: ?5, issue: "12", year: 2009, fpage: 3, lpage: nil) }
    end
  end

  context "with a citation that specifies the season" do
    let(:input) do
      "Journal of Some Unknown Studies; Vol 6, No 2: Fall/Winter 2011"
    end

    it { is_expected.to be_full.and be_known }

    it { is_expected.to have_attributes(volume: ?6, issue: ?2, year: 2011) }
  end

  context "when dealing with just a volume" do
    let(:input) do
      "Some Journal; Vol. 13 (1999)"
    end

    it { is_expected.to be_volume_only.and be_known }

    it { is_expected.to have_attributes(volume: "13", issue: "UNKNOWN", year: 1999) }
  end

  context "with an oddly structured volume" do
    let(:input) do
      "Journal of Oddities; 2020; Widgets"
    end

    it { is_expected.to be_volume_only.and be_known }
    it { is_expected.to have_attributes(volume: "2020 Widgets", issue: "UNKNOWN", year: 2020) }
  end

  context "when dealing with just an issue" do
    let(:input) do
      "Journal of Testing, Magic, and Journaling; 2025: Special Issue: Let's Test Issue Only Parsing"
    end

    it { is_expected.to be_issue_only.and be_known }

    it { is_expected.to have_attributes(volume: "UNKNOWN", issue: "Special Issue: Let's Test Issue Only Parsing", year: 2025) }
  end

  context "when dealing with an oddly structured issue" do
    let(:input) do
      "Journal of Textile and Apparel, Technology and Management; 2019: Special Issue - ITMA Show, Barcelona, Spain"
    end

    it { is_expected.to be_issue_only.and be_known }

    it { is_expected.to have_attributes(volume: "UNKNOWN", issue: "Special Issue - ITMA Show, Barcelona, Spain", year: 2019) }
  end

  context "with auto_create_volumes_and_issues set" do
    include Dry::Effects::Handler.Resolve

    let(:input) { "literally anything" }

    around do |example|
      provide auto_create_volumes_and_issues: true do
        example.run
      end
    end

    it { is_expected.to be_full.and be_known }

    it { is_expected.to have_attributes(volume: ?1, issue: ?1) }
  end

  context "with unparseable input" do
    let(:input) { "some random text" }

    it { is_expected.to be_unknown }
  end

  context "with a truncated format as the second argument" do
    let(:input) do
      [
        nil,
        "Some Journal, vol 12, iss 103"
      ]
    end

    it { is_expected.to be_full.and be_known }

    it { is_expected.to have_attributes(volume: "12", issue: "103") }
  end
end
