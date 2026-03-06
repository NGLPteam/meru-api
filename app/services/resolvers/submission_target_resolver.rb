# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionTarget}.
  #
  # @see SubmissionTarget
  # @see Types::SubmissionTargetType
  class SubmissionTargetResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsSubmissionTarget

    applies_policy_scope!

    type ::Types::SubmissionTargetType.connection_type, null: false

    resolves_model! ::SubmissionTarget

    filters_with! ::Filtering::Scopes::SubmissionTargets
  end
end
