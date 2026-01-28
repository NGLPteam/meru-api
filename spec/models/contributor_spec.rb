# frozen_string_literal: true

RSpec.describe Contributor, type: :model, disable_ordering_refresh: true do
  let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person }

  let_it_be(:collection_count) { 2 }
  let_it_be(:item_count) { 2 }

  let_it_be(:collection_contributions) { FactoryBot.create_list :collection_contribution, collection_count, contributor: }
  let_it_be(:item_contributions) { FactoryBot.create_list :item_contribution, item_count, contributor: }

  describe "#attach!" do
    it "can attach a collection" do
      expect do
        contributor.attach! FactoryBot.create :collection
      end.to change(CollectionContribution, :count).by(1).
        and change { contributor.reload.collection_contribution_count }.by(1).
        and change { contributor.reload.contribution_count }.by(1)
    end

    it "can attach an item" do
      expect do
        contributor.attach! FactoryBot.create :item
      end.to change(ItemContribution, :count).by(1).
        and change { contributor.reload.item_contribution_count }.by(1).
        and change { contributor.reload.contribution_count }.by(1)
    end
  end

  describe "#count_collection_contributions!" do
    context "when the collection contributions have been destroyed" do
      before do
        CollectionContribution.where(id: collection_contributions.map(&:id)).delete_all
      end

      it "can recalculate the contributions" do
        expect do
          contributor.count_collection_contributions!
        end.to change { contributor.reload.collection_contribution_count }.by(-collection_count).
          and change { contributor.reload.contribution_count }.by(-collection_count)
      end
    end
  end

  describe "#count_item_contributions!" do
    context "when the item contributions have been destroyed" do
      before do
        ItemContribution.where(id: item_contributions.map(&:id)).delete_all
      end

      it "can recalculate the contributions" do
        expect do
          contributor.count_item_contributions!
        end.to change { contributor.reload.item_contribution_count }.by(-item_count).
          and change { contributor.reload.contribution_count }.by(-item_count)
      end
    end
  end

  describe "#recount_contributions!" do
    context "when the contributions have been destroyed" do
      before do
        CollectionContribution.where(id: collection_contributions.map(&:id)).delete_all
        ItemContribution.where(id: item_contributions.map(&:id)).delete_all
      end

      it "can recalculate the contributions" do
        expect do
          contributor.recount_contributions!
        end.to change { contributor.reload.collection_contribution_count }.by(-collection_count).
          and change { contributor.reload.item_contribution_count }.by(-item_count).
          and change { contributor.reload.contribution_count }.by(-(item_count + collection_count))
      end
    end
  end

  describe "#safe_name" do
    context "with a blank name" do
      it "has the right value for an unknown kind" do
        expect(described_class.new.safe_name).to eq "(Unknown Contributor)"
      end

      it "has the right value for an organization" do
        expect(described_class.new(kind: :organization).safe_name).to eq "(Unknown Organization)"
      end

      it "has the right value for a person" do
        expect(described_class.new(kind: :person).safe_name).to eq "(Unknown Person)"
      end
    end
  end
end
