# frozen_string_literal: true

module Types
  # An edge in a {::Types::DepositorRequestTransitionConnectionType} for {DepositorRequestTransition}-type records.
  #
  # @see DepositorRequestTransition
  # @see ::Types::DepositorRequestTransitionConnectionType
  # @see ::Types::DepositorRequestTransitionType
  class DepositorRequestTransitionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `DepositorRequestTransition`.
    TEXT

    node_type ::Types::DepositorRequestTransitionType
  end
end
