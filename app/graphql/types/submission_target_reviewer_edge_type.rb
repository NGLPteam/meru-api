# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionTargetReviewerConnectionType} for {SubmissionTargetReviewer}-type records.
  #
  # @see SubmissionTargetReviewer
  # @see ::Types::SubmissionTargetReviewerConnectionType
  # @see ::Types::SubmissionTargetReviewerType
  class SubmissionTargetReviewerEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionTargetReviewer`.
    TEXT

    node_type ::Types::SubmissionTargetReviewerType
  end
end
