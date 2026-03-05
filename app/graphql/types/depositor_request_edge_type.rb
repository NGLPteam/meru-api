# frozen_string_literal: true

module Types
  # An edge in a {::Types::DepositorRequestConnectionType} for {DepositorRequest}-type records.
  #
  # @see DepositorRequest
  # @see ::Types::DepositorRequestConnectionType
  # @see ::Types::DepositorRequestType
  class DepositorRequestEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `DepositorRequest`.
    TEXT

    node_type ::Types::DepositorRequestType
  end
end
