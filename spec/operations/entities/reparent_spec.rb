# frozen_string_literal: true

RSpec.describe Entities::Reparent, type: :operation, grants_access: true do
  include ActiveJob::TestHelper

  let_it_be(:manager_role) { FactoryBot.create :role, :manager }

  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:other_community, refind: true) { FactoryBot.create :community }

  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: community }
  let_it_be(:item, refind: true) { FactoryBot.create :item, collection: }

  let_it_be(:user, refind: true) { FactoryBot.create :user }

  before do
    grant_access! manager_role, on: community, to: user
  end

  it "will reparent and clean up inherited authorization logic" do
    expect do
      perform_enqueued_jobs do
        expect_calling_with(other_community, collection).to succeed.with(collection)
      end
    end.to change { collection.reload.community_id }.from(community.id).to(other_community.id)
      .and change { collection.reload.hierarchical_parent }.from(community).to(other_community)
      .and change { CollectionPolicy.new(collection.reload, user:).update? }.from(true).to(false)
      .and change { ItemPolicy.new(item.reload, user:).update? }.from(true).to(false)
  end
end
