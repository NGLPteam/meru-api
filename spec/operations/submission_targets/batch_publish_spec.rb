# frozen_string_literal: true

RSpec.describe SubmissionTargets::BatchPublish, type: :operation do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let_it_be(:approved_submission, refind: true) do
    FactoryBot.create(:submission,
      :approved,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      title: "Test Approved Submission"
    )
  end

  let_it_be(:approved_entity, refind: true) { approved_submission.entity }

  let_it_be(:rejected_submission, refind: true) do
    FactoryBot.create(:submission,
      :rejected,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      title: "Test Rejected Submission"
    )
  end

  let_it_be(:rejected_entity, refind: true) { rejected_submission.entity }

  let_it_be(:user, refind: true) { FactoryBot.create(:user) }

  let(:submissions) { [approved_submission, rejected_submission] }

  it "enqueues a batch publication" do
    expect do
      expect_calling_with(submission_target, submissions, user:).to succeed.with(a_kind_of(SubmissionBatchPublication))
    end.to change(SubmissionBatchPublication, :count).by(1)
      .and change(SubmissionPublication, :count).by(2)
      .and change(SubmissionBatchPublicationTransition.to_pending, :count).by(1)
      .and change(SubmissionBatchPublicationTransition.to_batched, :count).by(1)
      .and keep_the_same(SubmissionBatchPublicationTransition.to_finished, :count)
      .and change(SubmissionPublicationTransition.to_pending, :count).by(2)
      .and change(SubmissionPublicationTransition.to_batched, :count).by(2)
      .and keep_the_same(SubmissionPublicationTransition.to_success, :count)
      .and keep_the_same(SubmissionPublicationTransition.to_failure, :count)
      .and have_enqueued_job(SubmissionPublications::PublishJob).twice

    expect do
      flush_enqueued_jobs
    end.to change { approved_entity.reload.submission_status }.from("submission_draft").to("submission_published")
      .and keep_the_same { rejected_entity.reload.submission_status }
      .and change { approved_submission.current_state(force_reload: true) }.from("approved").to("published")
      .and keep_the_same { rejected_submission.current_state(force_reload: true) }
      .and change(SubmissionBatchPublicationTransition.to_finished, :count).by(1)
  end
end
