# frozen_string_literal: true

RSpec.describe SubmissionPublications::PublishJob, type: :job do
  let_it_be(:submission_publication, refind: true) { FactoryBot.create(:submission_publication) }

  it_behaves_like "a pass-through operation job", "submission_publications.publish" do
    let(:job_arg) { submission_publication }
  end
end
