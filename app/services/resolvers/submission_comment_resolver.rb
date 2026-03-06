# frozen_string_literal: true

module Resolvers
  # A resolver for a {SubmissionComment}.
  #
  # @see SubmissionComment
  # @see Types::SubmissionCommentType
  class SubmissionCommentResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsSubmissionComment

    applies_policy_scope!

    type ::Types::SubmissionCommentType.connection_type, null: false

    resolves_model! ::SubmissionComment

    filters_with! ::Filtering::Scopes::SubmissionComments
  end
end
