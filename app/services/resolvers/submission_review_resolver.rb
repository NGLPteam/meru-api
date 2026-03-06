# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionReview}.
  #
  # @see SubmissionReview
  # @see Types::SubmissionReviewType
  class SubmissionReviewResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsSubmissionReview

    applies_policy_scope!

    type ::Types::SubmissionReviewType.connection_type, null: false

    resolves_model! ::SubmissionReview

    filters_with! ::Filtering::Scopes::SubmissionReviews
  end
end
