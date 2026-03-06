# frozen_string_literal: true

module Resolvers
  # A resolver for a {DepositorRequest}.
  #
  # @see DepositorRequest
  # @see Types::DepositorRequestType
  class DepositorRequestResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsDepositorRequest

    applies_policy_scope!

    type ::Types::DepositorRequestType.connection_type, null: false

    resolves_model! ::DepositorRequest

    filters_with! ::Filtering::Scopes::DepositorRequests
  end
end
