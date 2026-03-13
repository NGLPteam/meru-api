# frozen_string_literal: true

module Types
  # A connection type for {DepositorAgreementTransition}-typed records.
  #
  # @see DepositorAgreementTransition
  # @see ::Types::DepositorAgreementTransitionEdgeType
  # @see ::Types::DepositorAgreementTransitionType
  class DepositorAgreementTransitionConnectionType < Types::BaseConnection
    graphql_name "DepositorAgreementTransitionConnection"

    description <<~TEXT
    A connection type for `DepositorAgreementTransition`.
    TEXT

    edge_type ::Types::DepositorAgreementTransitionEdgeType
  end
end
