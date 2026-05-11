# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    module BaseInterface
      extend ::Support::GraphQLAPI::Enhancements::Interface

      edge_type_class ::Support::GQL::BaseEdge
      connection_type_class ::Support::GQL::BaseConnection

      field_class ::Support::GQL::BaseField
    end
  end
end
