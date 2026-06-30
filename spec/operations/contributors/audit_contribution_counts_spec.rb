# frozen_string_literal: true

RSpec.describe Contributors::AuditContributionCounts, type: :operation do
  let_it_be(:contributor_a) { FactoryBot.create :contributor, :person }

  let_it_be(:a_contributions) { FactoryBot.create_list :item_contribution, 2, contributor: contributor_a }

  let_it_be(:contributor_b) { FactoryBot.create :contributor, :organization }

  let_it_be(:b_contributions) { FactoryBot.create_list :collection_contribution, 2, contributor: contributor_b }

  let_it_be(:contributor_c) { FactoryBot.create :contributor, :organization }

  context "when everything is in sync" do
    it "updates nothing" do
      expect_calling.to succeed.with(0)
    end
  end

  context "when a contributor is out of sync" do
    before do
      Contributor.where(id: contributor_a).update_all(item_contribution_count: 0)
    end

    it "updates only the necessary row(s)" do
      expect_calling.to succeed.with(1)
    end

    context "when specifying an ID" do
      it "only sees what it has been told" do
        expect_calling_with(contributor_id: contributor_b.id).to succeed.with(0)
      end
    end
  end

  context "when contributions have been deleted without updating" do
    before do
      ItemContribution.delete_all
      CollectionContribution.delete_all
    end

    it "updates the necessary row(s)" do
      expect_calling.to succeed.with(3)
    end

    context "when specifying a list of IDs" do
      it "updates only the specified row(s)" do
        expect_calling_with(contributor_id: [contributor_a.id, contributor_c.id]).to succeed.with(1)
      end
    end
  end
end
