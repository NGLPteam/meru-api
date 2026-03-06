# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionReviewTransition}.
  #
  # @see SubmissionReviewTransition
  # @see Types::SubmissionReviewTransitionType
  class SubmissionReviewTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::SubmissionReviewTransitionType.connection_type, null: false

    resolves_model! ::SubmissionReviewTransition do
      object.submission_review_transitions.in_graphql_order
    end
  end
end
