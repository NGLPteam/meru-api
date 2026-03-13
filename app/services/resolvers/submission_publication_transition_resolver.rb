# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionPublicationTransition}.
  #
  # @see SubmissionPublicationTransition
  # @see Types::SubmissionPublicationTransitionType
  class SubmissionPublicationTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::SubmissionPublicationTransitionType.connection_type, null: false

    resolves_model! ::SubmissionPublicationTransition do
      object.submission_publication_transitions.in_graphql_order
    end
  end
end
