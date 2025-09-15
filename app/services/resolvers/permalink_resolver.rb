# frozen_string_literal: true

module Resolvers
  # A resolver for a {Permalink}.
  #
  # @see Permalink
  # @see Types::PermalinkType
  class PermalinkResolver < AbstractResolver
    include Resolvers::Enhancements::AppliesPolicyScope
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsPermalink

    type Types::PermalinkType.connection_type, null: false

    scope do
      if object.present?
        object.try(:permalinks) || ::Permalink.none
      else
        ::Permalink.all
      end
    end

    # filters_with! Filtering::Scopes::Permalinks
  end
end
