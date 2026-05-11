# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseUnion < ::GraphQL::Schema::Union
      edge_type_class ::Support::GQL::BaseEdge

      connection_type_class ::Support::GQL::BaseConnection
    end
  end
end
