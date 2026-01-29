# frozen_string_literal: true

RSpec.shared_context "parsed journal source" do
  let(:input) { nil }
  let(:volume) { nil }
  let(:issue) { nil }
  let(:year) { nil }
  let(:fpage) { nil }
  let(:lpage) { nil }

  let(:parsed_attrs) do
    {
      volume:,
      issue:,
      year:,
      fpage:,
      lpage:,
    }
  end

  let(:instance) { described_class.new(**parsed_attrs) }

  subject { instance }

  shared_examples_for "a valid parsed journal source" do |mode|
    it { is_expected.to be_valid }

    case mode
    when :full
      it { is_expected.to be_full }
      it { is_expected.not_to be_issue_only }
      it { is_expected.not_to be_volume_only }
    when :issue_only
      it { is_expected.not_to be_full }
      it { is_expected.to be_issue_only }
      it { is_expected.not_to be_volume_only }
    when :volume_only
      it { is_expected.not_to be_full }
      it { is_expected.not_to be_issue_only }
      it { is_expected.to be_volume_only }
    else
      it { is_expected.not_to be_known }
      it { is_expected.to be_unknown }
    end

    it "produces the expected monad" do
      expect(instance.to_monad).to be_some
    end

    context "when parsing its liquid drop" do
      let(:drop) { instance.to_liquid }

      subject { drop }

      case mode
      when :full
        it { is_expected.to be_exists }
        it { is_expected.to be_known }
        it { is_expected.to be_full }
        it { is_expected.not_to be_issue_only }
        it { is_expected.not_to be_volume_only }
      when :issue_only
        it { is_expected.to be_exists }
        it { is_expected.to be_known }
        it { is_expected.not_to be_full }
        it { is_expected.to be_issue_only }
        it { is_expected.not_to be_volume_only }
      when :volume_only
        it { is_expected.to be_exists }
        it { is_expected.to be_known }
        it { is_expected.not_to be_full }
        it { is_expected.not_to be_issue_only }
        it { is_expected.to be_volume_only }
      else
        it { is_expected.not_to be_exists }
        it { is_expected.not_to be_known }
        it { is_expected.to be_unknown }
      end
    end
  end

  shared_examples_for "an invalid parsed journal source" do
    it { is_expected.to be_invalid }
    it { is_expected.not_to be_known }

    it "produces the expected monad" do
      expect(instance.to_monad).to be_none
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context "parsed journal source", type: :parsed_journal_source
end
