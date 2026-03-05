# frozen_string_literal: true

module Types
  # A connection type for {SubmissionTargetReviewer}-typed records.
  #
  # @see SubmissionTargetReviewer
  # @see ::Types::SubmissionTargetReviewerEdgeType
  # @see ::Types::SubmissionTargetReviewerType
  class SubmissionTargetReviewerConnectionType < Types::BaseConnection
    graphql_name "SubmissionTargetReviewerConnection"

    description <<~TEXT
    A connection type for `SubmissionTargetReviewer`.
    TEXT

    edge_type ::Types::SubmissionTargetReviewerEdgeType
  end
end
