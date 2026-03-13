# frozen_string_literal: true

module Resolvers
  # A resolver for a {DepositorAgreementTransition}.
  #
  # @see DepositorAgreementTransition
  # @see Types::DepositorAgreementTransitionType
  class DepositorAgreementTransitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::DepositorAgreementTransitionType.connection_type, null: false

    resolves_model! ::DepositorAgreementTransition do
      object.depositor_agreement_transitions.in_graphql_order
    end
  end
end
