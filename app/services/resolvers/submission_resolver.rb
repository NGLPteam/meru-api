# frozen_string_literal: true

module Resolvers
  # A resolver for a {Submission}.
  #
  # @see Submission
  # @see Types::SubmissionType
  class SubmissionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsSubmission

    applies_policy_scope!

    type ::Types::SubmissionType.connection_type, null: false

    resolves_model! ::Submission

    filters_with! ::Filtering::Scopes::Submissions
  end
end
