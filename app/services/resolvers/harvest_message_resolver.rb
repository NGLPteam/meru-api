# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestMessage}.
  #
  # @see HarvestMessage
  # @see ::Types::HarvestMessageType
  class HarvestMessageResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::HarvestMessageType.connection_type, null: false

    resolves_model! ::HarvestMessage

    filters_with! Filtering::Scopes::HarvestMessages

    def resolve_default_scope
      super.in_default_order
    end
  end
end
