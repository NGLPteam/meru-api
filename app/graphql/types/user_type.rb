# frozen_string_literal: true

module Types
  # @see AnonymousUser
  # @see User
  class UserType < Types::AbstractModel
    implements Types::AccessGrantSubjectType
    implements Types::ExposesPermissionsType

    description "A known or anonymous user in the system. Registration and management is primarily handled through the WDP Keycloak instance."

    field :access_management, ::Types::AccessManagementType, null: false do
      description "The level of access management this user has for entities in the system."
    end

    field :anonymous, Boolean, null: false, method: :anonymous? do
      description "Is this an anonymous / unauthenticated user?"
    end

    field :email_verified, Boolean, null: false do
      description "Has this user's email been verified to work through Keycloak?"
    end

    field :email, String, null: true do
      description "A user's email. Depending on the upstream provider, this may not be set."
    end

    field :username, String, null: true do
      description "A unique username for the user. Depending on the upstream provider, this may not be set."
    end

    field :name, String, null: true do
      description "The user's full provided name. Depending on the upstream provider, this may not be set."
    end

    field :given_name, String, null: true do
      description "The user's given (first) name. Depending on the upstream provider, this may not be set."
    end

    field :family_name, String, null: true do
      description "The user's family (last) name. Depending on the upstream provider, this may not be set."
    end

    image_attachment_field :avatar, description: "A user's avatar"

    field :global_admin, Boolean, null: false, method: :has_global_admin_access? do
      description "Does this user have access to administer the entire instance?"
    end

    field :communities, resolver: Resolvers::AccessibleCommunityResolver do
      description "Query the communities this user has access to"
    end

    field :collections, resolver: Resolvers::AccessibleCollectionResolver do
      description "Query the collections this user has access to"
    end

    field :items, resolver: Resolvers::AccessibleItemResolver do
      description "Query the items this user has access to"
    end

    field :upload_access, Boolean, null: false, method: :has_any_upload_access? do
      description "Can this user upload anything at all?"
    end

    field :upload_token, String, null: true do
      description "If a user has any upload access, this token will allow them to do so."
    end

    field :access_grants, resolver: Resolvers::AccessGrants::UserResolver do
      description "All access grants for this user"
    end

    field :community_access_grants, resolver: Resolvers::AccessGrants::UserCommunityResolver do
      description "All access grants for this user on a community"
    end

    field :collection_access_grants, resolver: Resolvers::AccessGrants::UserCollectionResolver do
      description "All access grants for this user on a collection"
    end

    field :item_access_grants, resolver: Resolvers::AccessGrants::UserItemResolver do
      description "All access grants for this user on an item"
    end

    expose_authorization_rule :receive_review_requests?, <<~TEXT
    Whether this user is a reviewer on **any** submission targets, and should see information about
    potential review requests in the UI.

    This is meant to be checked on the `Query.viewer`.
    TEXT

    expose_authorization_rule :reset_password?, <<~TEXT
    Whether the current user has permission to reset this user's password.
    TEXT

    expose_authorization_rule :revalidate_instance?, <<~TEXT
    Whether this user has permission to trigger revalidation of the entire frontend.
    TEXT

    # @see AnonymousInterface#system_slug_id
    # @see User#system_slug_id
    # @return [String]
    def slug = object.system_slug_id
  end
end
