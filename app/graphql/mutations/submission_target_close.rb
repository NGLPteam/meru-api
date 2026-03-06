# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionTargetClose
  class SubmissionTargetClose < Mutations::BaseMutation
    description <<~TEXT
    Close a `SubmissionTarget`, preventing any new submissions from being made.
    TEXT

    field :submission_target, ::Types::SubmissionTargetType, null: true do
      description <<~TEXT
      The modified submission target, if successful.
      TEXT
    end

    argument :submission_target_id, ID, loads: Types::SubmissionTargetType, required: true do
      description <<~TEXT
      The ID of the {SubmissionTarget} to close.
      TEXT
    end

    performs_operation! "mutations.operations.submission_target_close"
  end
end
