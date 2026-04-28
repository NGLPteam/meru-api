# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionCreate
  class SubmissionCreate < Mutations::BaseMutation
    description <<~TEXT
    Create a single `Submission` record.
    TEXT

    field :submission, ::Types::SubmissionType, null: true do
      description <<~TEXT
      The newly-modified submission, if successful.
      TEXT
    end

    argument :submission_target_id, ID, loads: ::Types::SubmissionTargetType, required: true do
      description <<~TEXT
      The ID of the {SubmissionTarget} against which the submission is being made.
      TEXT
    end

    argument :schema_version_id, ID, loads: ::Types::SchemaVersionType, required: true do
      description <<~TEXT
      The ID of the {SchemaVersion} to be used for the submission.
      TEXT
    end

    argument :parent_entity_id, ID, loads: ::Types::EntityType, required: true do
      description <<~TEXT
      The ID of the parent entity for the submission.

      This is derived from one of the `depositTargets` of the specified `SubmissionTarget`.
      TEXT
    end

    argument :agreement_accepted, Boolean, required: false, default_value: false, replace_null_with_default: true do
      description <<~TEXT
      Whether or not the submitter has accepted the agreement for this submission.

      This must be true.
      TEXT
    end

    argument :title, String, required: true do
      description <<~TEXT
      The title of the submission.

      This gets passed to the entity when it is built.
      TEXT
    end

    performs_operation! "mutations.operations.submission_create"
  end
end
