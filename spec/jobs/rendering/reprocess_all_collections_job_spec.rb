# frozen_string_literal: true

RSpec.describe Rendering::ReprocessAllCollectionsJob, type: :job do
  let!(:collection) { FactoryBot.create(:collection) }

  it "enqueues an Entities::ReprocessLayoutsJob for each record" do
    expect do
      described_class.perform_now
    end.to have_enqueued_job(Entities::ReprocessLayoutsJob).once.with(collection)
  end
end
