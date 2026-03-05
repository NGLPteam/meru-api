# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestSet}.
  #
  # @see HarvestSet
  # @see ::Types::HarvestSetType
  class HarvestSetResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsHarvestSet

    applies_policy_scope!

    type ::Types::HarvestSetType.connection_type, null: false

    resolves_model! ::HarvestSet

    filters_with! Filtering::Scopes::HarvestSets
  end
end
