# frozen_string_literal: true

module Access
  # Types for Access-related operations and services.
  module Types
    extend ::Support::Typespace

    # @see AccessGrant
    AccessGrant = ModelInstance("AccessGrant")

    # A type matching something needs access to be granted to it.
    # In effect, an {Entity}.
    #
    # @see ::Accessible
    # @return [Dry::Types::Type]
    Accessible = Instance(::Accessible)

    # A list of {Accessible}s.
    #
    # @return [Dry::Types::Type]
    Accessibles = Coercible::Array.of(Accessible)

    # @see HierarchicalEntity
    Entity = Instance(::HierarchicalEntity)

    # Multiple entities, as an array.
    #
    # @return [Dry::Types::Type]
    Entities = Coercible::Array.of(Entity)

    # @see Role
    Role = ModelInstance("Role")

    # A symbolic identifier for a role.
    #
    # @see Roles::Types::Identifier
    # @return [Dry::Types::Type]
    RoleIdentifier = Roles::Types::Identifier

    # A role or a symbolic identifier for a role.
    #
    # @see Role
    # @see RoleIdentifier
    # @return [Dry::Types::Type]
    RoleInput = Role | RoleIdentifier

    # A type matching an identity that can be allowed to access {Accessible}s.
    # Presently, this is only {User}, but we want to allow for expansion to {UserGroup}.
    #
    # @see AccessGrantSubject
    # @see ::Types::AccessGrantSubjectType
    # @return [Dry::Types::Type]
    Subject = Instance(::AccessGrantSubject)

    # A type matching a {User}.
    #
    # @return [Dry::Types::Type]
    User = ModelInstance("User")
  end
end
