# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionBatchPublish
  class SubmissionBatchPublish < Mutations::BaseMutation
    description <<~TEXT
    Publish multiple submissions within a single submission target.

    This will enqueue the actual publications in the backend.
    TEXT

    field :submission_batch_publication, Types::SubmissionBatchPublicationType, null: true do
      description "The submission batch publication that was created to track this process."
    end

    field :submission_target, Types::SubmissionTargetType, null: true do
      description "The submission target that the submissions belong to."
    end

    argument :submission_target_id, ID, required: true, loads: Types::SubmissionTargetType do
      description "The ID of the submission target that the submissions belong to."
    end

    argument :submission_ids, [ID], required: true, loads: Types::SubmissionType do
      description "The IDs of the submissions to publish."
    end

    performs_operation! "mutations.operations.submission_batch_publish"
  end
end
