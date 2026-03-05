# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionReviewTransitionConnectionType} for {SubmissionReviewTransition}-type records.
  #
  # @see SubmissionReviewTransition
  # @see ::Types::SubmissionReviewTransitionConnectionType
  # @see ::Types::SubmissionReviewTransitionType
  class SubmissionReviewTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionReviewTransition`.
    TEXT

    node_type ::Types::SubmissionReviewTransitionType
  end
end
