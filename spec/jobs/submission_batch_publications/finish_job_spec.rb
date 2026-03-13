# frozen_string_literal: true

RSpec.describe SubmissionBatchPublications::FinishJob, type: :job do
  let_it_be(:submission_batch_publication, refind: true) do
    FactoryBot.create(:submission_batch_publication)
  end

  let(:batch) do
    GoodJob::Batch.new.tap do |b|
      b.properties[:submission_batch_publication] = submission_batch_publication
    end
  end

  let(:context) { {} }

  it "transitions the batch publication to finished" do
    expect do
      described_class.perform_now(batch, context)
    end.to change { submission_batch_publication.current_state(force_reload: true) }.to("finished")
  end
end
