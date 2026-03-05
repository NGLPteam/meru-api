# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionReviewConnectionType} for {SubmissionReview}-type records.
  #
  # @see SubmissionReview
  # @see ::Types::SubmissionReviewConnectionType
  # @see ::Types::SubmissionReviewType
  class SubmissionReviewEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionReview`.
    TEXT

    node_type ::Types::SubmissionReviewType
  end
end
