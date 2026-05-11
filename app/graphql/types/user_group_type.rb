# frozen_string_literal: true

module Types
  class UserGroupType < Types::BaseModel
    implements Types::AccessGrantSubjectType

    description <<~TEXT
    Not presently exposed through the API.
    TEXT

    field :name, String, null: false

    field :description, String, null: false

    field :users, resolver: Resolvers::UserGroupUserResolver

    field :access_grants, resolver: Resolvers::AccessGrants::UserGroupResolver,
      description: "All access grants for this group"

    field :community_access_grants, resolver: Resolvers::AccessGrants::UserGroupCommunityResolver,
      description: "All access grants for this group on a community"

    field :collection_access_grants, resolver: Resolvers::AccessGrants::UserGroupCollectionResolver,
      description: "All access grants for this group on a collection"

    field :item_access_grants, resolver: Resolvers::AccessGrants::UserGroupItemResolver,
      description: "All access grants for this group on an item"

    def slug
      object.keycloak_id
    end
  end
end
