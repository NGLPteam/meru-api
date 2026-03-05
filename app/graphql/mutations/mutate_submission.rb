# frozen_string_literal: true

module Mutations
  # @abstract
  # @see Mutations::CreateSubmission
  # @see Mutations::UpdateSubmission
  class MutateSubmission < Mutations::BaseMutation
    description <<~TEXT
    A base mutation that is used to share fields between `createSubmission` and `updateSubmission`.
    TEXT

    field :submission, Types::SubmissionType, null: true do
      description <<~TEXT
      The newly-modified submission, if successful.
      TEXT
    end
  end
end
