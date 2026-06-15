# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionDestroy
  class SubmissionDestroy < Mutations::BaseMutation
    description <<~TEXT
    Destroy a single `Submission` record.
    TEXT

    argument :submission_id, ID, loads: Types::SubmissionType, required: true do
      description <<~TEXT
      The submission to destroy.
      TEXT
    end

    performs_operation! "mutations.operations.submission_destroy", destroy: true
  end
end
