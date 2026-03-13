# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionPublish
  class SubmissionPublish < Mutations::BaseMutation
    description <<~TEXT
    Publish a single submission.

    To publish multiple submissions at once, use `submissionBatchPublish`.
    TEXT

    field :entity, Types::EntityType, null: true do
      description <<~TEXT
      The entity that the published submission belongs to, if successful.
      TEXT
    end

    field :submission, Types::SubmissionType, null: true do
      description <<~TEXT
      The submission that was published, if successful.
      TEXT
    end

    field :submission_publication, Types::SubmissionPublicationType, null: true do
      description <<~TEXT
      The actual record of the publication, if successful.
      TEXT
    end

    argument :submission_id, ID, required: true, loads: ::Types::SubmissionType do
      description <<~TEXT
      The ID for the submission to publish.
      TEXT
    end

    performs_operation! "mutations.operations.submission_publish"
  end
end
