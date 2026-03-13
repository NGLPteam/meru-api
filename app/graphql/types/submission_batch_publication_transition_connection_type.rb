# frozen_string_literal: true

module Types
  # A connection type for {SubmissionBatchPublicationTransition}-typed records.
  #
  # @see SubmissionBatchPublicationTransition
  # @see ::Types::SubmissionBatchPublicationTransitionEdgeType
  # @see ::Types::SubmissionBatchPublicationTransitionType
  class SubmissionBatchPublicationTransitionConnectionType < Types::BaseConnection
    graphql_name "SubmissionBatchPublicationTransitionConnection"

    description <<~TEXT
    A connection type for `SubmissionBatchPublicationTransition`.
    TEXT

    edge_type ::Types::SubmissionBatchPublicationTransitionEdgeType
  end
end
