# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionBatchPublicationTransitionConnectionType} for {SubmissionBatchPublicationTransition}-type records.
  #
  # @see SubmissionBatchPublicationTransition
  # @see ::Types::SubmissionBatchPublicationTransitionConnectionType
  # @see ::Types::SubmissionBatchPublicationTransitionType
  class SubmissionBatchPublicationTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionBatchPublicationTransition`.
    TEXT

    node_type ::Types::SubmissionBatchPublicationTransitionType
  end
end
