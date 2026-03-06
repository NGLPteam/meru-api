# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::SubmissionTargetOpen
  class SubmissionTargetOpen < Mutations::BaseMutation
    description <<~TEXT
    Open a `SubmissionTarget`, allowing new submissions to be made.
    TEXT

    field :submission_target, ::Types::SubmissionTargetType, null: true do
      description <<~TEXT
      The modified submission target, if successful.
      TEXT
    end

    argument :submission_target_id, ID, loads: Types::SubmissionTargetType, required: true do
      description <<~TEXT
      The ID of the {SubmissionTarget} to open.
      TEXT
    end

    performs_operation! "mutations.operations.submission_target_open"
  end
end
