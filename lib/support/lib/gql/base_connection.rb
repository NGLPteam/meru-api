# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseConnection < ::Support::GQL::AbstractObject
      # add `nodes` and `pageInfo` fields, as well as `edge_type(...)` and `node_nullable(...)` overrides
      include GraphQL::Types::Relay::ConnectionBehaviors

      implements Support::GQL::PaginatedType

      # Override built-in pageInfo field type with our type, supporting page-based pagination
      get_field("pageInfo").type = GraphQL::Schema::Member::BuildType.parse_type(Support::GQL::PageInfoType, null: false)

      edge_nullable false
      node_nullable false
      edges_nullable false
    end
  end
end
