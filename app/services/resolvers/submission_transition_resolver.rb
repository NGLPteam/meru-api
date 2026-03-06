# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionTransition}.
  #
  # @see SubmissionTransition
  # @see Types::SubmissionTransitionType
  class SubmissionTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::SubmissionTransitionType.connection_type, null: false

    resolves_model! ::SubmissionTransition do
      object.submission_transitions.in_graphql_order
    end
  end
end
