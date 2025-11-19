# frozen_string_literal: true

RSpec.describe Rendering::ReprocessAllItemsJob, type: :job do
  let!(:item) { FactoryBot.create(:item) }

  it "enqueues an Entities::ReprocessLayoutsJob for each record" do
    expect do
      described_class.perform_now
    end.to have_enqueued_job(Entities::ReprocessLayoutsJob).once.with(item)
  end
end
