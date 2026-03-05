# frozen_string_literal: true

module Types
  # A connection type for {SubmissionComment}-typed records.
  #
  # @see SubmissionComment
  # @see ::Types::SubmissionCommentEdgeType
  # @see ::Types::SubmissionCommentType
  class SubmissionCommentConnectionType < Types::BaseConnection
    graphql_name "SubmissionCommentConnection"

    description <<~TEXT
    A connection type for `SubmissionComment`.
    TEXT

    edge_type ::Types::SubmissionCommentEdgeType
  end
end
