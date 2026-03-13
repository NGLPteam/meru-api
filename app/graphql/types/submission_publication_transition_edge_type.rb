# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionPublicationTransitionConnectionType} for {SubmissionPublicationTransition}-type records.
  #
  # @see SubmissionPublicationTransition
  # @see ::Types::SubmissionPublicationTransitionConnectionType
  # @see ::Types::SubmissionPublicationTransitionType
  class SubmissionPublicationTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionPublicationTransition`.
    TEXT

    node_type ::Types::SubmissionPublicationTransitionType
  end
end
