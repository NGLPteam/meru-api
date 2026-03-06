# frozen_string_literal: true

module Mutations
  # @abstract
  # @see Mutations::CreateSubmissionComment
  # @see Mutations::UpdateSubmissionComment
  class MutateSubmissionComment < Mutations::BaseMutation
    description <<~TEXT
    A base mutation that is used to share fields between `createSubmissionComment` and `updateSubmissionComment`.
    TEXT

    field :submission_comment, Types::SubmissionCommentType, null: true do
      description <<~TEXT
      The newly-modified submission comment, if successful.
      TEXT
    end

    argument :content, String, required: true do
      description <<~TEXT
      The content of the comment.
      TEXT
    end
  end
end
