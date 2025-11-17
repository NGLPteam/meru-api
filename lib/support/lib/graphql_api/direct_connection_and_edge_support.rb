# frozen_string_literal: true

module Support
  module GraphQLAPI
    module DirectConnectionAndEdgeSupport
      extend ActiveSupport::Concern

      module ClassMethods
        def use_direct_connection_and_edge!(
          base_name: graphql_name,
          connection_klass_name: "Types::#{base_name}ConnectionType",
          edge_klass_name: "Types::#{base_name}EdgeType"
        )
          define_singleton_method(:edge_type) do
            @edge_type ||= edge_klass_name.constantize
          end

          define_singleton_method(:connection_type) do
            @connection_type ||= connection_klass_name.constantize
          end
        end
      end
    end
  end
end
