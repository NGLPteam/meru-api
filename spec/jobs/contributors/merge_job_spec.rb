# frozen_string_literal: true

RSpec.describe Contributors::MergeJob, type: :job do
  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: }
  let_it_be(:item, refind: true) { FactoryBot.create :item, collection: }

  let_it_be(:source_contributor, refind: true) { FactoryBot.create :contributor, :organization }
  let_it_be(:target_contributor, refind: true) { FactoryBot.create :contributor, :person }

  let_it_be(:harvest_contributor, refind: true) do
    FactoryBot.create :harvest_contributor, :organization, contributor: source_contributor
  end

  let_it_be(:source_collection_contribution, refind: true) do
    FactoryBot.create :collection_contribution, collection:, contributor: source_contributor, updated_at: 1.week.ago
  end

  let_it_be(:source_item_contribution, refind: true) do
    FactoryBot.create :item_contribution, item:, contributor: source_contributor
  end

  let_it_be(:existing_target_collection_contribution, refind: true) do
    FactoryBot.create :collection_contribution, collection:, contributor: target_contributor, updated_at: 6.months.ago
  end

  it "merges contributions from the source to the target" do
    expect do
      described_class.perform_now(source_contributor, target_contributor)
    end.to execute_safely
      .and change(Contributor, :count).by(-1)
      .and change(CollectionContribution, :count).by(-1)
      .and keep_the_same(ItemContribution, :count)
      .and keep_the_same { target_contributor.collection_contributions.count }
      .and change { target_contributor.item_contributions.count }.by(1)
      .and change { existing_target_collection_contribution.reload.updated_at }
      .and change { harvest_contributor.reload.contributor }.from(source_contributor).to(target_contributor)
  end
end
