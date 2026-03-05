# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestMetadataMapping}.
  #
  # @see HarvestMetadataMapping
  # @see ::Types::HarvestMetadataMappingType
  class HarvestMetadataMappingResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsHarvestMetadataMapping

    applies_policy_scope!

    type ::Types::HarvestMetadataMappingType.connection_type, null: false

    resolves_model! ::HarvestMetadataMapping

    # filters_with! Filtering::Scopes::HarvestMetadataMappings
  end
end
