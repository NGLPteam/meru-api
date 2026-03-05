# frozen_string_literal: true

module Types
  # A connection type for {SubmissionTransition}-typed records.
  #
  # @see SubmissionTransition
  # @see ::Types::SubmissionTransitionEdgeType
  # @see ::Types::SubmissionTransitionType
  class SubmissionTransitionConnectionType < Types::BaseConnection
    graphql_name "SubmissionTransitionConnection"

    description <<~TEXT
    A connection type for `SubmissionTransition`.
    TEXT

    edge_type ::Types::SubmissionTransitionEdgeType
  end
end
