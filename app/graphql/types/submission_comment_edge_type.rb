# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionCommentConnectionType} for {SubmissionComment}-type records.
  #
  # @see SubmissionComment
  # @see ::Types::SubmissionCommentConnectionType
  # @see ::Types::SubmissionCommentType
  class SubmissionCommentEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionComment`.
    TEXT

    node_type ::Types::SubmissionCommentType
  end
end
