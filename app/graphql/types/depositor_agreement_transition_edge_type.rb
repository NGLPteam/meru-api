# frozen_string_literal: true

module Types
  # An edge in a {::Types::DepositorAgreementTransitionConnectionType} for {DepositorAgreementTransition}-type records.
  #
  # @see DepositorAgreementTransition
  # @see ::Types::DepositorAgreementTransitionConnectionType
  # @see ::Types::DepositorAgreementTransitionType
  class DepositorAgreementTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `DepositorAgreementTransition`.
    TEXT

    node_type ::Types::DepositorAgreementTransitionType
  end
end
