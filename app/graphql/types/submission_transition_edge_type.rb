# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionTransitionConnectionType} for {SubmissionTransition}-type records.
  #
  # @see SubmissionTransition
  # @see ::Types::SubmissionTransitionConnectionType
  # @see ::Types::SubmissionTransitionType
  class SubmissionTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionTransition`.
    TEXT

    node_type ::Types::SubmissionTransitionType
  end
end
