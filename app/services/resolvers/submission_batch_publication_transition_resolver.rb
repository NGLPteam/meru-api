# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionBatchPublicationTransition}.
  #
  # @see SubmissionBatchPublicationTransition
  # @see Types::SubmissionBatchPublicationTransitionType
  class SubmissionBatchPublicationTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::SubmissionBatchPublicationTransitionType.connection_type, null: false

    resolves_model! ::SubmissionBatchPublicationTransition do
      object.submission_batch_publication_transitions.in_graphql_order
    end
  end
end
