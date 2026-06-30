# frozen_string_literal: true

RSpec.describe Entities::ReprocessAllDerivativesJob, type: :job do
  let!(:community) { fixture(:community) }
  let!(:collection) { fixture(:collection) }

  it "enqueues the expected amount of subjobs" do
    expect do
      described_class.perform_now
    end.to have_enqueued_job(Entities::ReprocessDerivativesJob).at_least(2).times
  end
end
