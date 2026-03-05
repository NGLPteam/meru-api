# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionTargetTransitionConnectionType} for {SubmissionTargetTransition}-type records.
  #
  # @see SubmissionTargetTransition
  # @see ::Types::SubmissionTargetTransitionConnectionType
  # @see ::Types::SubmissionTargetTransitionType
  class SubmissionTargetTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionTargetTransition`.
    TEXT

    node_type ::Types::SubmissionTargetTransitionType
  end
end
