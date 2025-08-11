# frozen_string_literal: true

RSpec.describe Entities::ReparentJob, type: :job do
  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:old_parent, refind: true) { FactoryBot.create(:collection, community:) }
  let_it_be(:new_parent, refind: true) { community }

  let_it_be(:child, refind: true) { FactoryBot.create :collection, parent: old_parent, title: "Child" }

  it "asynchronously reparents an entity" do
    expect do
      described_class.perform_now new_parent, child
    end.to change { child.reload.contextual_parent }.from(old_parent).to(community)
  end
end
