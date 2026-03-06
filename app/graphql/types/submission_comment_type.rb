# frozen_string_literal: true

module Types
  # @see SubmissionComment
  # @see ::Types::SubmissionCommentConnectionType
  # @see ::Types::SubmissionCommentEdgeType
  class SubmissionCommentType < Types::AbstractModel
    description <<~TEXT
    A comment on a `Submission`.
    TEXT

    use_direct_connection_and_edge!

    field :submission, "::Types::SubmissionType", null: false do
      description <<~TEXT
      The submission that this comment is on.
      TEXT
    end

    field :user, "::Types::UserType", null: false do
      description <<~TEXT
      The user that made this comment.
      TEXT
    end

    field :role, Types::SubmissionCommentRoleType, null: false do
      description <<~TEXT
      The role of the comment, quickly delineating if it was from the submitter or a reviewer.
      TEXT
    end

    field :content, String, null: false do
      description <<~TEXT
      The content of the comment.
      TEXT
    end

    load_association! :submission

    load_association! :user
  end
end
