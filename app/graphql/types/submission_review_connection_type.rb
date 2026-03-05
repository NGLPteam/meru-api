# frozen_string_literal: true

module Types
  # A connection type for {SubmissionReview}-typed records.
  #
  # @see SubmissionReview
  # @see ::Types::SubmissionReviewEdgeType
  # @see ::Types::SubmissionReviewType
  class SubmissionReviewConnectionType < Types::BaseConnection
    graphql_name "SubmissionReviewConnection"

    description <<~TEXT
    A connection type for `SubmissionReview`.
    TEXT

    edge_type ::Types::SubmissionReviewEdgeType
  end
end
