# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionTargetTransition}.
  #
  # @see SubmissionTargetTransition
  # @see Types::SubmissionTargetTransitionType
  class SubmissionTargetTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::SubmissionTargetTransitionType.connection_type, null: false

    resolves_model! ::SubmissionTargetTransition do
      object.submission_target_transitions.in_graphql_order
    end
  end
end
