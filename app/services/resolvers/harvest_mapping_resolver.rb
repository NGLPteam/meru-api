# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestMapping}.
  #
  # @see HarvestMapping
  # @see ::Types::HarvestMappingType
  class HarvestMappingResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsHarvestMapping

    applies_policy_scope!

    type ::Types::HarvestMappingType.connection_type, null: false

    resolves_model! ::HarvestMapping

    # filters_with! Filtering::Scopes::HarvestMappings
  end
end
