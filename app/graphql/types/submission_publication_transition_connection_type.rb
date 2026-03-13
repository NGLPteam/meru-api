# frozen_string_literal: true

module Types
  # A connection type for {SubmissionPublicationTransition}-typed records.
  #
  # @see SubmissionPublicationTransition
  # @see ::Types::SubmissionPublicationTransitionEdgeType
  # @see ::Types::SubmissionPublicationTransitionType
  class SubmissionPublicationTransitionConnectionType < Types::BaseConnection
    graphql_name "SubmissionPublicationTransitionConnection"

    description <<~TEXT
    A connection type for `SubmissionPublicationTransition`.
    TEXT

    edge_type ::Types::SubmissionPublicationTransitionEdgeType
  end
end
