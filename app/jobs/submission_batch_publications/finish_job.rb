# frozen_string_literal: true

module SubmissionBatchPublications
  # A callback job for when the GoodJob batch is complete.
  #
  # @see SubmissionTargets::BatchPublisher
  class FinishJob < ApplicationJob
    queue_as :depositing

    # @param [GoodJob::Batch] batch
    # @param [Hash] _context
    # @return [void]
    def perform(batch, _context)
      sbp = batch.properties[:submission_batch_publication]

      # Quietly ignore if the batch publication is already finished
      sbp.try(:transition_to, :finished)
    end
  end
end
