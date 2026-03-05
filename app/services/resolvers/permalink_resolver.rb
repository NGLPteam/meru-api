# frozen_string_literal: true

module Resolvers
  # A resolver for a {Permalink}.
  #
  # @see Permalink
  # @see ::Types::PermalinkType
  class PermalinkResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsPermalink

    applies_policy_scope!

    type ::Types::PermalinkType.connection_type, null: false

    resolves_model! ::Permalink

    # filters_with! Filtering::Scopes::Permalinks
  end
end
