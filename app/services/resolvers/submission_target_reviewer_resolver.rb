# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionTargetReviewer}.
  #
  # @see SubmissionTargetReviewer
  # @see Types::SubmissionTargetReviewerType
  class SubmissionTargetReviewerResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsSubmissionTargetReviewer

    applies_policy_scope!

    type ::Types::SubmissionTargetReviewerType.connection_type, null: false

    resolves_model! ::SubmissionTargetReviewer

    filters_with! ::Filtering::Scopes::SubmissionTargetReviewers
  end
end
