# frozen_string_literal: true

RSpec.describe Rendering::ReprocessAllCommunitiesJob, type: :job do
  let!(:community) { FactoryBot.create(:community) }

  it "enqueues an Entities::ReprocessLayoutsJob for each record" do
    expect do
      described_class.perform_now
    end.to have_enqueued_job(Entities::ReprocessLayoutsJob).once.with(community)
  end
end
