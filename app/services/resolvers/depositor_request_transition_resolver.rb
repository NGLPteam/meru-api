# frozen_string_literal: true

module Resolvers
  # A resolver for a {DepositorRequestTransition}.
  #
  # @see DepositorRequestTransition
  # @see Types::DepositorRequestTransitionType
  class DepositorRequestTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::DepositorRequestTransitionType.connection_type, null: false

    resolves_model! ::DepositorRequestTransition do
      object.depositor_request_transitions.in_graphql_order
    end
  end
end
