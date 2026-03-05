# frozen_string_literal: true

module Types
  # A connection type for {DepositorRequest}-typed records.
  #
  # @see DepositorRequest
  # @see ::Types::DepositorRequestEdgeType
  # @see ::Types::DepositorRequestType
  class DepositorRequestConnectionType < Types::BaseConnection
    graphql_name "DepositorRequestConnection"

    description <<~TEXT
    A connection type for `DepositorRequest`.
    TEXT

    edge_type ::Types::DepositorRequestEdgeType
  end
end
