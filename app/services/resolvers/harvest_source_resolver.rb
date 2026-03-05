# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestSource}.
  #
  # @see HarvestSource
  # @see ::Types::HarvestSourceType
  class HarvestSourceResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsHarvestSource

    applies_policy_scope!

    type ::Types::HarvestSourceType.connection_type, null: false

    resolves_model! ::HarvestSource, from_object: false
  end
end
