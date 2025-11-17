# frozen_string_literal: true

module Types
  class EntityLinkType < Types::AbstractModel
    description "A link between different entities"

    implements Types::OrderingEntryableType

    field :source, Types::EntityType, null: false
    field :target, Types::EntityType, null: false
    field :operator, Types::EntityLinkOperatorType, null: false
    field :scope, Types::EntityLinkScopeType, null: false

    field :source_community, "Types::CommunityType", null: true
    field :source_collection, "Types::CollectionType", null: true
    field :source_item, "Types::ItemType", null: true

    field :target_community, "Types::CommunityType", null: true
    field :target_collection, "Types::CollectionType", null: true
    field :target_item, "Types::ItemType", null: true
  end
end
