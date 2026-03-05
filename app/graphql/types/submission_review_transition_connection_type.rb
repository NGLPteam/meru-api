# frozen_string_literal: true

module Types
  # A connection type for {SubmissionReviewTransition}-typed records.
  #
  # @see SubmissionReviewTransition
  # @see ::Types::SubmissionReviewTransitionEdgeType
  # @see ::Types::SubmissionReviewTransitionType
  class SubmissionReviewTransitionConnectionType < Types::BaseConnection
    graphql_name "SubmissionReviewTransitionConnection"

    description <<~TEXT
    A connection type for `SubmissionReviewTransition`.
    TEXT

    edge_type ::Types::SubmissionReviewTransitionEdgeType
  end
end
