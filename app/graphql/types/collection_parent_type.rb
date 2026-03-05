# frozen_string_literal: true

module Types
  class CollectionParentType < Types::BaseUnion
    possible_types Types::CommunityType, Types::CollectionType

    description <<~TEXT
    The parent of a collection, which can be either a community or another collection.
    TEXT

    class << self
      def resolve_type(object, context)
        object.graphql_node_type
      end
    end
  end
end
