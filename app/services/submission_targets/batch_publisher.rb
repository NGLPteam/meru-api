# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTargets::BatchPublish
  class BatchPublisher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission_target, Types::SubmissionTarget

      param :submissions, Types::Submissions

      option :user, Types::User.optional, optional: true
    end

    standard_execution!

    # @return [<SubmissionPublication>]
    attr_reader :submission_publications

    # @return [SubmissionBatchPublication]
    attr_reader :submission_batch_publication

    # @return [Dry::Monads::Success(SubmissionBatchPublication)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield enqueue!
      end

      Success(submission_batch_publication)
    end

    wrapped_hook! def prepare
      @submission_batch_publication = submission_target.submission_batch_publications.create!(user:)

      @submission_publications = []

      super
    end

    wrapped_hook! def enqueue
      GoodJob::Batch.enqueue(on_finish: SubmissionBatchPublications::FinishJob, submission_batch_publication:) do
        submissions.each.with_index(1) do |submission, index|
          enqueue_publication_for!(submission, index)
        end

        submission_batch_publication.transition_to! :batched
      end

      super
    end

    private

    # @param [Submission] submission
    # @param [Integer] batch_position
    # @return [void]
    def enqueue_publication_for!(submission, batch_position)
      publication = submission.submission_publications.create!(user:, submission_batch_publication:, batch_position:)

      SubmissionPublications::PublishJob.perform_later(publication)

      publication.transition_to! :batched

      submission_publications << publication
    end
  end
end
