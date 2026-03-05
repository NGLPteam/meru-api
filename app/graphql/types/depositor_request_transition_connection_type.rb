# frozen_string_literal: true

module Types
  # A connection type for {DepositorRequestTransition}-typed records.
  #
  # @see DepositorRequestTransition
  # @see ::Types::DepositorRequestTransitionEdgeType
  # @see ::Types::DepositorRequestTransitionType
  class DepositorRequestTransitionConnectionType < Types::BaseConnection
    graphql_name "DepositorRequestTransitionConnection"

    description <<~TEXT
    A connection type for `DepositorRequestTransition`.
    TEXT

    edge_type ::Types::DepositorRequestTransitionEdgeType
  end
end
