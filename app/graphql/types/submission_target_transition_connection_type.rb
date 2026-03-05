# frozen_string_literal: true

module Types
  # A connection type for {SubmissionTargetTransition}-typed records.
  #
  # @see SubmissionTargetTransition
  # @see ::Types::SubmissionTargetTransitionEdgeType
  # @see ::Types::SubmissionTargetTransitionType
  class SubmissionTargetTransitionConnectionType < Types::BaseConnection
    graphql_name "SubmissionTargetTransitionConnection"

    description <<~TEXT
    A connection type for `SubmissionTargetTransition`.
    TEXT

    edge_type ::Types::SubmissionTargetTransitionEdgeType
  end
end
