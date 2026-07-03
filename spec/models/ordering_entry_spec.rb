# frozen_string_literal: true

RSpec.describe OrderingEntry, type: :model do
  include_context "entity authorization testing"

  let_it_be(:series, refind: true) { FactoryBot.create(:collection, :series, community:) }

  # the papers ordering lists in descending published order, so "previous" will be a newer date, etc.
  let_it_be(:previous_paper, refind: true) { FactoryBot.create(:item, :paper, title: "Previous Paper", published: VariablePrecisionDate.parse("2026-07-02"), collection: series) }
  let_it_be(:paper, refind: true) { FactoryBot.create(:item, :paper, title: "Current Paper", published: VariablePrecisionDate.parse("2026-07-01"), collection: series) }
  let_it_be(:hidden_paper, refind: true) { FactoryBot.create(:item, :paper, :hidden, title: "Hidden Paper", published: VariablePrecisionDate.parse("2026-06-30"), collection: series) }
  let_it_be(:next_paper, refind: true) { FactoryBot.create(:item, :paper, title: "Next Paper", published: VariablePrecisionDate.parse("2026-06-29"), collection: series) }

  let_it_be(:ordering, refind: true) { series.ordering("papers") }

  let(:previous_entry) { entry_for(previous_paper) }
  let(:entry) { entry_for(paper) }
  let(:next_entry) { entry_for(next_paper) }

  def entry_for(item) = described_class.find_by(ordering:, entity: item)

  subject { entry }

  its(:next_sibling) { is_expected.to eq next_entry }
  its(:prev_sibling) { is_expected.to eq previous_entry }

  specify "the hidden paper uses Ordering.owned_by_or_ordering correctly" do
    expect(ordering).to be_in Ordering.owned_by_or_ordering(hidden_paper)
  end

  specify "the hidden paper is not included in the ordering", :aggregate_failures do
    expect(ordering.entries_count).to eq 3

    expect(entry_for(hidden_paper)).to be_nil
  end

  specify "when hiding a paper, it is removed from the ordering" do
    expect do
      paper.hide!
    end.to change(described_class, :count).by(-2)
      .and change { ordering.reload.entries_count }.by(-1)
      .and change { entry_for(paper) }.from(entry).to(nil)
      .and change { previous_entry.reload.next_sibling }.from(entry).to(next_entry)
      .and change { next_entry.reload.prev_sibling }.from(entry).to(previous_entry)
  end

  specify "when unhiding the hidden paper, it moves into the ordering" do
    expect do
      hidden_paper.reveal!
    end.to change(described_class, :count).by(2)
      .and change { ordering.reload.entries_count }.by(1)
      .and change { entry_for(hidden_paper) }.from(nil).to(be_present)
      .and change { entry_for(hidden_paper)&.prev_sibling }.from(nil).to(entry)
      .and change { entry_for(hidden_paper)&.next_sibling }.from(nil).to(next_entry)
      .and change { entry.reload.next_sibling }.from(next_entry).to(satisfy("the entry for the previously hidden paper") { |e| e&.entity == hidden_paper })
      .and change { next_entry.reload.prev_sibling }.from(entry).to(satisfy("the entry for the previously hidden paper") { |e| e&.entity == hidden_paper })
  end
end
