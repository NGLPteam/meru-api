# frozen_string_literal: true

module Types
  # @abstract
  class BaseUnion < ::Support::GQL::BaseUnion
    edge_type_class ::Types::BaseEdge

    connection_type_class ::Types::BaseConnection
  end
end
