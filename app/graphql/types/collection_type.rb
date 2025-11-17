# frozen_string_literal: true

module Types
  class CollectionType < Types::AbstractModel
    implements Types::AccessibleType
    implements Types::AttributableType
    implements Types::EntityType
    implements Types::ChildEntityType
    implements Types::ContributableType
    implements Types::HarvestTargetType
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

    description "A collection of items"

    field :attributions, [Types::CollectionAttributionType, { null: false }], null: false do
      description "Attributions for the collection."
    end

    field :community, Types::CommunityType, null: false

    field :parent, "Types::CollectionParentType", null: true
    field :children, connection_type, null: false, deprecation_reason: "Use Collection.collections"

    field :has_collections, Boolean, null: false,
      description: "Whether this collection has any child collections"

    field :has_items, Boolean, null: false,
      description: "Whether this collection has any child items"

    field :collections, resolver: Resolvers::SubcollectionResolver, connection: true
    field :first_collection, resolver: Resolvers::SingleSubcollectionResolver
    field :related_collections, resolver: Resolvers::RelatedCollectionResolver, connection: true
    field :contributions, resolver: Resolvers::CollectionContributionResolver, connection: true
    field :items, resolver: Resolvers::ItemResolver, connection: true
    field :first_item, resolver: Resolvers::SingleSubitemResolver

    field :access_grants, resolver: Resolvers::AccessGrants::CollectionResolver

    field :user_access_grants, resolver: Resolvers::AccessGrants::UserCollectionResolver,
      description: "Access grants for specific users"

    field :user_group_access_grants, resolver: Resolvers::AccessGrants::UserGroupCollectionResolver,
      description: "Not presently used"

    load_association! :attributions

    # @return [Boolean]
    def has_collections
      object.children.exists?
    end

    # @return [Boolean]
    def has_items
      object.items.exists?
    end

    # @return [Community, Collection]
    def parent
      object.root? ? object.community : object.parent
    end
  end
end
