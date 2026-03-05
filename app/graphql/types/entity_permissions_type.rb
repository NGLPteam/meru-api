# frozen_string_literal: true

module Types
  # @see Types::ChildEntityType
  # @see Types::EntityType
  module EntityPermissionsType
    include Types::BaseInterface

    description <<~TEXT
    A common interface for certain entity-specific permissions,
    scoped to the current user.
    TEXT

    implements ::Types::SubmittableType

    expose_authorization_rule :alter_schema_version?, <<~TEXT
    Whether the current user has permission to alter the schema version of this entity.

    Submission drafts will be denied, even if the user would otherwise have permission.
    TEXT

    expose_authorization_rule :create_assets?, <<~TEXT
    Whether the current user has permission to create assets under this entity.
    TEXT

    expose_authorization_rule :create_collections?, <<~TEXT
    Whether the current user has permission to create collections under this entity.
    TEXT

    expose_authorization_rule :create_items?, <<~TEXT
    Whether the current user has permission to create items under this entity.
    TEXT

    expose_authorization_rule :manage_access?, <<~TEXT
    Whether the current user has permission to manage access to this entity.

    This opens up `grantAccess` and `revokeAccess` mutations.
    TEXT

    expose_authorization_rule :purge?, <<~TEXT
    Whether the current user has permission to purge this entity.
    TEXT

    expose_authorization_rule :reparent?, <<~TEXT
    Whether the current user has permission to reparent this entity.

    Submission drafts will be denied, even if the user would otherwise have permission.
    TEXT

    expose_authorization_rule :revalidate?, <<~TEXT
    Whether the current user has permission to revalidate this entity.
    TEXT
  end
end
