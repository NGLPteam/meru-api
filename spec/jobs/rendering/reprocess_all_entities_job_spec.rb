# frozen_string_literal: true

RSpec.describe Rendering::ReprocessAllEntitiesJob, type: :job do
  pending "add some examples to (or delete) #{__FILE__}"

  it "enqueues jobs for all entities" do
    expect do
      described_class.perform_now
    end.to have_enqueued_job(Rendering::ReprocessAllCommunitiesJob).once
      .and have_enqueued_job(Rendering::ReprocessAllCollectionsJob).once
      .and have_enqueued_job(Rendering::ReprocessAllItemsJob).once
  end
end
