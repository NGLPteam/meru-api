# frozen_string_literal: true

module Types
  class ItemType < Types::AbstractModel
    implements Types::AccessibleType
    implements Types::AttributableType
    implements Types::EntityType
    implements Types::ChildEntityType
    implements Types::ContributableType
    implements Types::HasEntityAnalytics
    implements Types::HasDOIType
    implements Types::HasHarvestModificationStatusType
    implements Types::HasSchemaPropertiesType
    implements Types::PermalinkableType
    implements Types::AttachableType
    implements Types::OrderingEntryableType
    implements Types::SchemaInstanceType
    implements Types::SearchableType

    use_direct_connection_and_edge!

    description "An item that belongs to a collection"

    field :attributions, [Types::ItemAttributionType, { null: false }], null: false do
      description "Attributions for the item."
    end

    field :collection, Types::CollectionType, null: false
    field :community, Types::CommunityType, null: false
    field :parent, "Types::ItemParentType", null: true
    field :children, connection_type, null: false, deprecation_reason: "Use Item.items"

    field :has_items, Boolean, null: false,
      description: "Whether this item has any child items"

    field :contributions, resolver: Resolvers::ItemContributionResolver, connection: true
    field :items, resolver: Resolvers::SubitemResolver, connection: true
    field :first_item, resolver: Resolvers::SingleSubitemResolver
    field :related_items, resolver: Resolvers::RelatedItemResolver, connection: true

    field :access_grants, resolver: Resolvers::AccessGrants::CollectionResolver

    field :user_access_grants, resolver: Resolvers::AccessGrants::UserCollectionResolver,
      description: "Access grants for specific users"

    field :user_group_access_grants, resolver: Resolvers::AccessGrants::UserGroupCollectionResolver,
      description: "Not presently used"

    load_association! :attributions

    # @return [Boolean]
    def has_items
      object.children.exists?
    end

    # @return [Collection, Item]
    def parent
      object.root? ? object.collection : object.parent
    end
  end
end
