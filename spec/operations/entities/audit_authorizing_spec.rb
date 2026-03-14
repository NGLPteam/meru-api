# frozen_string_literal: true

RSpec.describe Entities::AuditAuthorizing, type: :operation do
  let!(:collection) { FactoryBot.create :collection }

  let!(:subcollection) { FactoryBot.create :collection, parent: collection, community: collection.community }

  context "when an entity is moved" do
    it "prunes the stale row(s)" do
      expect do
        subcollection.parent = nil

        subcollection.save!
      end.to change(AuthorizingEntity, :count).by(1)

      expect do
        expect_calling.to succeed
      end.to change(AuthorizingEntity, :count).by(-2)
    end
  end
end
