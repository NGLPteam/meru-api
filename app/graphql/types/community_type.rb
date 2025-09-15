# frozen_string_literal: true

module Types
  # A GraphQL representation of a {Community}.
  class CommunityType < Types::AbstractModel
    implements Types::AccessibleType
    implements Types::EntityType
    implements Types::HarvestTargetType
    implements Types::HasEntityAnalytics
    implements Types::HasSchemaPropertiesType
    implements Types::PermalinkableType
    implements Types::AttachableType
    implements Types::SchemaInstanceType
    implements Types::SearchableType

    description "A community of users"

    field :hero_image_layout, Types::HeroImageLayoutType, null: false,
      description: "The layout to use when rendering this community's hero image."

    field :tagline, String, null: true

    field :collections, resolver: Resolvers::CollectionResolver

    field :position, Integer, null: true
    field :name, String, null: false, deprecation_reason: "Use Community.title"
    field :metadata, GraphQL::Types::JSON, null: true

    field :first_collection, resolver: Resolvers::SingleSubcollectionResolver
    field :first_item, resolver: Resolvers::SingleSubitemResolver

    field :access_grants, resolver: Resolvers::AccessGrants::CommunityResolver

    field :user_access_grants, resolver: Resolvers::AccessGrants::UserCommunityResolver,
      description: "Access grants for specific users"

    field :user_group_access_grants, resolver: Resolvers::AccessGrants::UserGroupCommunityResolver,
      description: "Not presently used"

    image_attachment_field :logo,
      description: "A logo for the community"
  end
end
